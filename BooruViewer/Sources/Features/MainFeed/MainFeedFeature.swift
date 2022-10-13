import Foundation
import ComposableArchitecture
import SankakuAPI

struct IndexedPost: Equatable {
    let index: Int
    let post: Post
}

struct MainFeedFeature: ReducerProtocol {

    private enum Constant {
        static let limit = 50
        static let nextPageLoadRange = 25
    }

    @Dependency(\.sankakuAPI) var sankakuAPI

    struct State: Equatable {
        var posts: [IndexedPost] = []
        var searchQuery = ""
        var searchTags: [Tag] = []
        var tagSuggestions: [Tag] = []

        var canLoadMore = true
        var isLoading = false
        var nextPageId: String?

        var detailFeedState: DetailFeedFeature.State?
    }

    enum Action: Equatable {
        case appear
        case loadMorePosts(index: Int)
        case reload
        case setSearchQuery(String)
        case setSearchTags([Tag])
        case presentDetailFeed(Post)
        case dismissDetailFeed

        case postsResponse(PostsResponse)
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
            return loadMore(state: state)

        case let .loadMorePosts(index):
            guard
                !state.isLoading,
                state.canLoadMore,
                state.posts.count - index <= Constant.nextPageLoadRange
            else {
                return .none
            }

            state.isLoading = true

            return loadMore(state: state)

        case .reload:
            state.posts = []
            state.nextPageId = nil
            state.isLoading = false
            state.canLoadMore = true

            return loadMore(state: state)

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
            state.detailFeedState = .init(post: post)

            return .none

        case .dismissDetailFeed:
            state.detailFeedState = nil

            return .none

        case let .postsResponse(response):
            state.nextPageId = response.meta.next
            state.canLoadMore = response.data.count >= Constant.limit

            let newPosts = response.data.enumerated().map { index, post in
                IndexedPost(index: state.posts.count + index, post: post)
            }

            state.posts.append(contentsOf: newPosts)
            state.isLoading = false

            return .none

        case let .suggestTagsResponse(tagSuggestions):
            state.tagSuggestions = tagSuggestions.filter { !state.searchTags.contains($0) }

            return .none

        case .detailFeedAction:
            // Do nothing
            return .none
        }
    }

    // MARK: - Private Methods

    private func loadMore(state: State) -> Effect<Action, Never> {
        .task {
            let response = try await sankakuAPI.getPosts(
                tags: state.searchTags.map(\.name),
                limit: Constant.limit,
                next: state.nextPageId
            )

            return .postsResponse(response)
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
