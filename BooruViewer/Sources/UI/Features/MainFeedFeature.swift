import Foundation
import ComposableArchitecture
import SankakuAPI

struct MainFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var didAppear = false
        var feedPhase: FeedPhase = .idle
        var posts: IdentifiedArrayOf<Post> = []
    }

    enum Action: Equatable {
        case appear
        case refresh
        case postAppeared(Post)

        case updateFeedState(FeedState)
    }

    let sankakuAPI: SankakuAPI
    let feed: Feed

    init() {
        let configuration: URLSessionConfiguration = .default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity

        let urlSession = URLSession(configuration: configuration)
        self.sankakuAPI = SankakuAPI(urlSession: urlSession)
        self.feed = FeedImpl(sankakuAPI: sankakuAPI)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .appear:
            guard !state.didAppear else {
                return .none
            }

            feed.reload()

            return .run { send in
                for await feedState in feed.stateStream {
                    await send(.updateFeedState(feedState))
                }
            }

        case .refresh:
            feed.reload()

            return .none

        case let .postAppeared(post):
            guard let index = state.posts.index(id: post.id) else {
                return .none
            }

            feed.loadPage(forItemAt: index)

            return .none

        case let .updateFeedState(newFeedState):
            state.feedPhase = newFeedState.phase
            state.posts = IdentifiedArray(uniqueElements: newFeedState.posts)

            return .none
        }
    }

}
