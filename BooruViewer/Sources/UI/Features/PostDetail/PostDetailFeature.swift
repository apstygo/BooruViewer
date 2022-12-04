import ComposableArchitecture
import SankakuAPI

struct PostDetailFeature: ReducerProtocol {

    struct State {
        struct Recommended {
            var posts: IdentifiedArrayOf<Post> = []
            var feedPhase: FeedPhase = .idle
        }

        let post: Post

        var didAppear = false
        var recommended = Recommended()
    }

    enum Action: Equatable {
        case appear
        case recommendedPostAppeared(Post)
        case openRecommendedPost(Post)

        case updateRecommendedFeedState(FeedState)
    }

    private let recommendedFeed: Feed

    init() {
        @Dependency(\.sankakuAPI) var api
        self.recommendedFeed = FeedImpl(sankakuAPI: api)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        func loadRecommended() {
            recommendedFeed.customTags = ["recommended_for_post:\(state.post.id)"]
            recommendedFeed.reload()
        }

        switch action {
        case .appear:
            guard !state.didAppear else {
                return .none
            }

            state.didAppear = true
            loadRecommended()

            return .run { send in
                for await feedState in recommendedFeed.stateStream {
                    await send(.updateRecommendedFeedState(feedState))
                }
            }

        case let .recommendedPostAppeared(post):
            guard let postIndex = state.recommended.posts.index(id: post.id) else {
                return .none
            }

            recommendedFeed.loadPage(forItemAt: postIndex)

            return .none

        case let .openRecommendedPost(post):
            // TODO: Implement
            return .none

        case let .updateRecommendedFeedState(feedState):
            state.recommended.feedPhase = feedState.phase
            state.recommended.posts = .init(uniqueElements: feedState.posts)
            return .none
        }
    }

}
