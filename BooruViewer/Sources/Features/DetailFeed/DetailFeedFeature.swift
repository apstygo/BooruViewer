import ComposableArchitecture
import SankakuAPI

struct DetailFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var currentPage: DetailPageFeature.State.ID

        var pageStates: IdentifiedArrayOf<DetailPageFeature.State> = []
    }

    enum Action: Equatable {
        case appear
        case scrollToPage(DetailPageFeature.State.ID)

        case setPosts([Post])

        case detailPageAction(Int, DetailPageFeature.Action)
    }

    @Dependency(\.feedManager) var feedManager

    var body: some ReducerProtocol<State, Action> {
        Reduce(coreReduce)
            .forEach(\.pageStates, action: /Action.detailPageAction) {
                DetailPageFeature()
            }
    }

    func coreReduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .appear:
            return .task {
                return await .setPosts(feedManager.posts)
            }

        case let .scrollToPage(pageId):
            state.currentPage = pageId

            if pageId == -1 {
                return .task {
                    await feedManager.loadNextPage()
                    return await .setPosts(feedManager.posts)
                }
            }
            else {
                return .none
            }

        case let .setPosts(posts):
            state.pageStates = .init(uniqueElements: posts.map { .init(post: $0) })

            return .none

        case .detailPageAction:
            // Do nothing
            return .none
        }
    }

}
