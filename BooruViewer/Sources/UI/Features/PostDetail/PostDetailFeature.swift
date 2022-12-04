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

        fileprivate let recommendedFeed: Feed

        init(post: Post) {
            self.post = post

            @Dependency(\.sankakuAPI) var api
            self.recommendedFeed = FeedImpl(sankakuAPI: api)
        }
    }

    enum Action: Equatable {
        case appear
        case recommendedPostAppeared(Post)
        case openRecommendedPost(Post)

        case updateRecommendedFeedState(FeedState)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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

            print("🔴 \(postIndex)")
            state.recommendedFeed.loadPage(forItemAt: postIndex)

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
