import Foundation
import ComposableArchitecture
import SankakuAPI

struct IndexedPost: Equatable {
    let index: Int
    let post: Post
}

struct MainFeedFeature: ReducerProtocol {

    private enum Constant {
        static let nextPageLoadRange = 25
    }

    @Dependency(\.sankakuAPI) var sankakuAPI
    @Dependency(\.feedManager) var feedManager

    struct State: Equatable {
        var posts: [IndexedPost] = []
        var searchQuery = ""
        var searchTags: [Tag] = []
        var tagSuggestions: [Tag] = []
        var feedManagerState: FeedManagerState = .idle
        var forceScrollIndex: Int?

        var detailFeedState: DetailFeedFeature.State?
    }

    enum Action: Equatable {
        case appear
        case loadMorePosts(index: Int)
        case reload
        case setSearchQuery(String)
        case setSearchTags([Tag])
        case presentDetailFeed(IndexedPost)
        case dismissDetailFeed

        case loadResponse([Post], FeedManagerState)
        case suggestTagsResponse([Tag])

        case detailFeedAction(DetailFeedFeature.Action)
    }

    struct LoadPostsID { }
    struct SuggestTagsID { }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.coreReduce)
            .ifLet(\.detailFeedState, action: /Action.detailFeedAction) {
                DetailFeedFeature()
            }
    }

    func coreReduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return load(state: state)

        case let .loadMorePosts(index):
            guard
                state.feedManagerState.allowsLoading,
                state.posts.count - index == Constant.nextPageLoadRange
            else {
                return .none
            }

            return load(state: state)

        case .reload:
            state.posts = []
            state.feedManagerState = .idle

            return load(state: state, reset: true)

        case let .setSearchQuery(query):
            state.searchQuery = query

            if query.isEmpty {
                state.tagSuggestions = []
                return .cancel(id: SuggestTagsID.self)
            }
            else {
                // TODO: Add debounce
                return suggestTags(state: state)
            }

        case let .setSearchTags(tags):
            guard tags != state.searchTags else {
                return .none
            }

            state.searchTags = tags

            return .task { .reload }

        case let .presentDetailFeed(post):
            state.detailFeedState = .init(postIndex: post.index)

            return .none

        case .dismissDetailFeed:
            state.detailFeedState = nil

            return .none

        case let .loadResponse(posts, feedManagerState):
            state.posts = posts.enumerated().map { IndexedPost(index: $0, post: $1) }
            state.feedManagerState = feedManagerState

            return .none

        case let .suggestTagsResponse(tagSuggestions):
            state.tagSuggestions = tagSuggestions.filter { !state.searchTags.contains($0) }

            return .none

        case let .detailFeedAction(.scrollToPost(postIndex)):
            state.forceScrollIndex = postIndex

            return .none

        case .detailFeedAction:
            // Do nothing
            return .none
        }
    }

    // MARK: - Private Methods

    private func load(state: State, reset: Bool = false) -> Effect<Action, Never> {
        .task {
            if reset {
                await feedManager.reload()
            }
            else {
                await feedManager.loadNextPage()
            }

            return await .loadResponse(feedManager.posts, feedManager.state)
        }
        .cancellable(id: LoadPostsID.self, cancelInFlight: true)
    }

    private func suggestTags(state: State) -> Effect<Action, Never> {
        .task {
            let tags = try await sankakuAPI.autoSuggestTags(for: state.searchQuery)
            return .suggestTagsResponse(tags)
        }
        .cancellable(id: SuggestTagsID.self, cancelInFlight: true)
    }

}

// MARK: - Helpers

extension FeedManagerState {

    fileprivate var allowsLoading: Bool {
        switch self {
        case .idle, .error:
            return true

        case .loading, .finished:
            return false
        }
    }

}
