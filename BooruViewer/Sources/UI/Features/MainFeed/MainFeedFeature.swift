import Foundation
import ComposableArchitecture
import SankakuAPI

struct MainFeedFeature: ReducerProtocol {

    struct State {
        var didAppear = false
        var feedPhase: FeedPhase = .idle
        var posts: IdentifiedArrayOf<Post> = []
        var searchText = ""
        var tags: IdentifiedArrayOf<TagToken> = []
        var suggestedTags: IdentifiedArrayOf<TagToken> = []
        var filters = GetPostsFilters()

        var destination: Destination?
    }

    enum Action {
        case appear
        case refresh
        case presentFilters
        case dismissFilters
        case postAppeared(Post)
        case openPost(Post)
        case dismissPost
        case updateSearchText(String)
        case updateTags(IdentifiedArrayOf<TagToken>)
        case openLogin
        case dismissLogin

        case updateFeedState(FeedState)
        case tagsResponse([Tag])

        case filterEditor(FilterEditorFeature.Action)
        case postDetail(PostDetailFeature.Action)
        case login(LoginFeature.Action)
    }

    enum Destination {
        case filterEditor(FilterEditorFeature.State)
        case postDetail(PostDetailFeature.State)
        case login(LoginFeature.State)
    }

    private enum Operation: Hashable {
        case loadTagSuggestions
    }

    private let sankakuAPI: SankakuAPI
    private let feed: Feed

    init() {
        @Dependency(\.sankakuAPI) var sharedAPI

        self.sankakuAPI = sharedAPI
        self.feed = FeedImpl(sankakuAPI: sharedAPI)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.filterEditorState, action: /Action.filterEditor) {
                FilterEditorFeature()
            }
            .ifLet(\.postDetailState, action: /Action.postDetail) {
                PostDetailFeature()
            }
            .ifLet(\.loginState, action: /Action.login) {
                LoginFeature()
            }
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        func reload() {
            feed.filters = state.filters
            feed.setTagTokens(state.tags)
            feed.reload()
        }

        switch action {
        case .appear:
            guard !state.didAppear else {
                return .none
            }

            state.didAppear = true

            feed.reload()

            return .run { send in
                for await feedState in feed.stateStream {
                    await send(.updateFeedState(feedState))
                }
            }

        case .refresh:
            reload()

            return .none

        case .presentFilters:
            state.destination = .filterEditor(.init(filters: state.filters))

            return .none

        case let .postAppeared(post):
            guard let index = state.posts.index(id: post.id) else {
                return .none
            }

            feed.loadPage(forItemAt: index)

            return .none

        case let .openPost(post):
            state.destination = .postDetail(.init(post: post))

            return .none

        case .dismissPost:
            state.destination = nil

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

            // FIXME: Debounce tag search
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

        case .openLogin:
            state.destination = .login(.init())

            return .none

        case .dismissLogin:
            state.destination = nil

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

        case .dismissFilters:
            state.destination = nil

            return .none

        case .filterEditor(.apply):
            guard let newFilters = state.filterEditorState?.filters else {
                assertionFailure("Filter editor should be present at this point.")
                return .none
            }

            state.filters = newFilters
            state.destination = nil

            reload()

            return .none

        case .filterEditor:
            // Do nothing
            return .none

        case .postDetail:
            // Do nothing
            return .none

        case .login:
            // Do nothing
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

extension MainFeedFeature.State {

    var filterEditorState: FilterEditorFeature.State? {
        get {
            switch destination {
            case let .filterEditor(state):
                return state

            default:
                return nil
            }
        }
        set {
            destination = newValue.map { .filterEditor($0) }
        }
    }

    var postDetailState: PostDetailFeature.State? {
        get {
            switch destination {
            case let .postDetail(state):
                return state

            default:
                return nil
            }
        }
        set {
            destination = newValue.map { .postDetail($0) }
        }
    }

    var loginState: LoginFeature.State? {
        get {
            switch destination {
            case let .login(state):
                return state

            default:
                return nil
            }
        }
        set {
            destination = newValue.map { .login($0) }
        }
    }

}
