import ComposableArchitecture
import SankakuAPI

struct DetailPageFeature: ReducerProtocol {

    struct State: Equatable {
        let post: Post
        var recommendedPosts: TaskResult<[Post]>?
    }

    enum Action: Equatable {
        case appear
        case retryLoading

        case recommendenPostsResponse(TaskResult<[Post]>)
    }

    @Dependency(\.sankakuAPI) var sankakuAPI

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return loadRecommendedPosts(for: state)

        case .retryLoading:
            return loadRecommendedPosts(for: state)

        case let .recommendenPostsResponse(result):
            state.recommendedPosts = result

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
