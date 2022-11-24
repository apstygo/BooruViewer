import Foundation
import ComposableArchitecture
import SankakuAPI

struct MainFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var didAppear = false
        var feedPhase: FeedPhase = .idle
        var posts: IdentifiedArrayOf<Post> = []
        var searchText = ""
        var tags: IdentifiedArrayOf<TagToken> = []
        var suggestedTags: IdentifiedArrayOf<TagToken> = []
    }

    enum Action: Equatable {
        case appear
        case refresh
        case postAppeared(Post)
        case updateSearchText(String)
        case updateTags(IdentifiedArrayOf<TagToken>)

        case updateFeedState(FeedState)
        case tagsResponse([Tag])
    }

    private enum Operation: Hashable {
        case loadTagSuggestions
    }

    let sankakuAPI: SankakuAPI
    let feed: Feed

    init() {
        let configuration: URLSessionConfiguration = .default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity

        let urlSession = URLSession(configuration: configuration)
        self.sankakuAPI = SankakuAPI(urlSession: urlSession)
        self.feed = FeedImpl(sankakuAPI: sankakuAPI)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        func reload() {
            feed.setTagTokens(state.tags)
            feed.reload()
        }

        switch action {
        case .appear:
            guard !state.didAppear else {
                return .none
            }

            feed.reload()

            return .run { send in
                for await feedState in feed.stateStream {
                    await send(.updateFeedState(feedState))
                }
            }

        case .refresh:
            reload()

            return .none

        case let .postAppeared(post):
            guard let index = state.posts.index(id: post.id) else {
                return .none
            }

            feed.loadPage(forItemAt: index)

            return .none

        case let .updateSearchText(newSearchText):
            state.searchText = newSearchText
            state.suggestedTags = []

            guard !newSearchText.isEmpty else {
                return .cancel(id: Operation.loadTagSuggestions)
            }

            let trimmed = newSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

            guard trimmed == newSearchText else {
                state.tags.append(.raw(trimmed))
                state.searchText = ""

                reload()

                return .cancel(id: Operation.loadTagSuggestions)
            }

            return .task {
                let tags = try await sankakuAPI.autoSuggestTags(for: newSearchText)
                return .tagsResponse(tags)
            }
            .cancellable(id: Operation.loadTagSuggestions, cancelInFlight: true)

        case let .updateTags(newTags):
            guard newTags != state.tags else {
                return .none
            }

            state.tags = newTags

            reload()

            return .none

        case let .updateFeedState(newFeedState):
            state.feedPhase = newFeedState.phase
            state.posts = IdentifiedArray(uniqueElements: newFeedState.posts)

            return .none

        case let .tagsResponse(newSuggestedTags):
            let tagTokens: [TagToken] = newSuggestedTags
                .filter { token in
                    !state.tags.contains { token.name == $0.tagName }
                }
                .map { .tag($0) }

            state.suggestedTags = IdentifiedArray(uncheckedUniqueElements: tagTokens)

            return .none
        }
    }

}

// MARK: - Helpers

extension Feed {

    fileprivate func setTagTokens(_ tagTokens: IdentifiedArrayOf<TagToken>) {
        tags = tagTokens.compactMap {
            guard case let .tag(tag) = $0 else {
                return nil
            }

            return tag
        }

        customTags = tagTokens.compactMap {
            guard case let .raw(string) = $0 else {
                return nil
            }

            return string
        }
    }

}
