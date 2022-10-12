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
    }

    @Dependency(\.sankakuAPI) var sankakuAPI

    struct State: Equatable {
        var posts: [IndexedPost] = []
        var canLoadMore = true
        var isLoading = false
        var nextPageId: String?
    }

    enum Action: Equatable {
        case appear
        case loadMorePosts(index: Int)

        case postsError
        case postsResponse(PostsResponse)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return sankakuAPI.getPosts(limit: Constant.limit, next: state.nextPageId)
                .map { Action.postsResponse($0) }
                .replaceError(with: .postsError)
                .receive(on: RunLoop.main)
                .eraseToEffect()

        case let .loadMorePosts(index):
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

        case .postsError:
            return .none
        }
    }

}
