import ComposableArchitecture
import SankakuAPI

struct IndexedPost: Equatable {
    let index: Int
    let post: Post
}

struct MainFeedFeature: ReducerProtocol {

    @Dependency(\.sankakuAPI) var sankakuAPI

    struct State: Equatable {
        var posts: [IndexedPost] = []
        var canLoadMore = true
        var isLoading = false
    }

    enum Action: Equatable {
        case appear
        case loadMorePosts(index: Int)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return .none

        case let .loadMorePosts(index):
            return .none
        }
    }

}
