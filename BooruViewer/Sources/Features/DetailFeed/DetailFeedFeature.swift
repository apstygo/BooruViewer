import ComposableArchitecture
import SankakuAPI

struct DetailFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var postIndex: Int
        var posts: [IndexedPost] = []
    }

    enum Action: Equatable {
        case appear
        case scrollToPost(Int)

        case setPosts([Post])
    }

    @Dependency(\.feedManager) var feedManager

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return .task {
                return await .setPosts(feedManager.posts)
            }

        case let .scrollToPost(postIndex):
            state.postIndex = postIndex

            return .none

        case let .setPosts(posts):
            state.posts = posts.enumerated().map { IndexedPost(index: $0, post: $1) }

            return .none
        }
    }

}
