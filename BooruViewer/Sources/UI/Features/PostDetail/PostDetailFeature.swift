import ComposableArchitecture
import SankakuAPI

struct PostDetailFeature: ReducerProtocol {

    struct State {
        struct Recommended {
            var posts: IdentifiedArrayOf<Post> = []
            var feedPhase: FeedPhase = .idle
        }

        let post: Post
        fileprivate let recommendedFeed: Feed

        var didAppear = false
        var recommended = Recommended()

        @Indirect var postDetailState: PostDetailFeature.State?
        @Indirect var mainFeedState: MainFeedFeature.State?

        init(post: Post) {
            self.post = post

            @Dependency(\.sankakuAPI) var api
            self.recommendedFeed = FeedImpl(sankakuAPI: api)
        }
    }

    indirect enum Action {
        case appear
        case recommendedPostAppeared(Post)
        case openRecommendedPost(Post)
        case dismissPost
        case openMainFeedWithTag(Tag)
        case dismissMainFeed

        case updateRecommendedFeedState(FeedState)

        case postDetail(PostDetailFeature.Action)
        case mainFeed(MainFeedFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.postDetailState, action: /Action.postDetail) {
                PostDetailFeature()
            }
            .ifLet(\.mainFeedState, action: /Action.mainFeed) {
                MainFeedFeature()
            }
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        func loadRecommended() {
            state.recommendedFeed.customTags = ["recommended_for_post:\(state.post.id)"]
            state.recommendedFeed.reload()
        }

        switch action {
        case .appear:
            guard !state.didAppear else {
                return .none
            }

            state.didAppear = true
            loadRecommended()

            return .run { [feed = state.recommendedFeed] send in
                for await feedState in feed.stateStream {
                    await send(.updateRecommendedFeedState(feedState))
                }
            }

        case let .recommendedPostAppeared(post):
            guard let postIndex = state.recommended.posts.index(id: post.id) else {
                return .none
            }

            state.recommendedFeed.loadPage(forItemAt: postIndex)

            return .none

        case let .openRecommendedPost(post):
            state.postDetailState = .init(post: post)

            return .none

        case .dismissPost:
            state.postDetailState = nil

            return .none

        case let .openMainFeedWithTag(tag):
            state.mainFeedState = .init(tag: tag)

            return .none

        case .dismissMainFeed:
            state.mainFeedState = nil

            return .none

        case let .updateRecommendedFeedState(feedState):
            state.recommended.feedPhase = feedState.phase
            state.recommended.posts = .init(uniqueElements: feedState.posts)
            return .none

        case .postDetail:
            // Do nothing
            return .none

        case .mainFeed:
            // Do nothing
            return .none
        }
    }

}
