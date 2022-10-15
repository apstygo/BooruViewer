import ComposableArchitecture
import SankakuAPI

struct DetailFeedFeature: ReducerProtocol {

    enum Mode: Equatable {
        case dynamic
        case `static`(posts: [Post])
    }

    struct State: Equatable {
        let mode: Mode
        var currentPage: DetailPageFeature.State.ID
        var pageStates: IdentifiedArrayOf<DetailPageFeature.State>
        var didAppear = false

        init(mode: Mode, currentPage: DetailPageFeature.State.ID) {
            self.mode = mode
            self.currentPage = currentPage

            switch mode {
            case let .static(posts):
                self.pageStates = .init(uniqueElements: posts.map { .init(post: $0) })

            case .dynamic:
                self.pageStates = []
            }
        }
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
            guard !state.didAppear else {
                return .none
            }

            state.didAppear = true

            switch state.mode {
            case .static:
                return .none

            case .dynamic:
                return .task { await .setPosts(feedManager.posts) }
            }

        case let .scrollToPage(pageId):
            state.currentPage = pageId

            guard case .dynamic = state.mode, pageId == -1 else {
                return .none
            }

            return .task {
                await feedManager.loadNextPage()
                return await .setPosts(feedManager.posts)
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
