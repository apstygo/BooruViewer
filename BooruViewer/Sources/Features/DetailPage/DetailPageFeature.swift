import ComposableArchitecture
import SankakuAPI

struct DetailPageFeature: ReducerProtocol {

    struct State: Equatable {
        let post: Post
        var recommendedPosts: TaskResult<[Post]>?

        var detailFeedState: DetailFeedFeature.State?
    }

    indirect enum Action: Equatable {
        case appear
        case retryLoading
        case tapRecommendedPost(Post)
        case dismissDetailFeed

        case recommendenPostsResponse(TaskResult<[Post]>)

        case detailFeedAction(DetailFeedFeature.Action)
    }

    @Dependency(\.sankakuAPI) var sankakuAPI

    var body: some ReducerProtocol<State, Action> {
        Reduce(coreReduce)
            .ifLet(\.detailFeedState, action: /Action.detailFeedAction) {
                DetailFeedFeature()
            }
    }

    func coreReduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return loadRecommendedPosts(for: state)

        case .retryLoading:
            return loadRecommendedPosts(for: state)

        case let .tapRecommendedPost(post):
            guard case let .success(posts) = state.recommendedPosts else {
                return .none
            }

            state.detailFeedState = .init(mode: .static(posts: posts), currentPage: post.id)

            return .none

        case .dismissDetailFeed:
            state.detailFeedState = nil

            return .none

        case let .recommendenPostsResponse(result):
            state.recommendedPosts = result

            return .none

        case .detailFeedAction:
            // Do nothing
            return .none
        }
    }

    func loadRecommendedPosts(for state: State) -> Effect<Action, Never> {
        return .task { [post = state.post] in
            let result = await TaskResult {
                try await sankakuAPI.getPosts(recommendedFor: post.id)
            }

            return .recommendenPostsResponse(result)
        }
    }

}

extension DetailPageFeature.State: Identifiable {

    var id: Int {
        post.id
    }

}
