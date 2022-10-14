import ComposableArchitecture
import SankakuAPI

struct DetailFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var postIndex: Int
        var posts: [IndexedPost] = []

        var pageStates: [Post: DetailPageFeature.State] = [:]
    }

    enum Action: Equatable {
        case appear
        case scrollToPost(Int)

        case setPosts([Post])

        case detailPageAction(Post, DetailPageFeature.Action)
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

            if postIndex == state.posts.count {
                return .task {
                    await feedManager.loadNextPage()
                    return await .setPosts(feedManager.posts)
                }
            }
            else {
                return .none
            }

        case let .setPosts(posts):
            state.posts = posts.enumerated().map { IndexedPost(index: $0, post: $1) }

            var pageStates: [Post: DetailPageFeature.State] = [:]

            for post in posts {
                pageStates[post] = .init(post: post)
            }

            state.pageStates = pageStates

            return .none

        case .detailPageAction:
            // Do nothing
            return .none
        }
    }

}
