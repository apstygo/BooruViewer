import Foundation
import ComposableArchitecture
import SankakuAPI

struct MainFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var didAppear = false
        var feedState = FeedState()
    }

    enum Action: Equatable {
        case appear
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

        case let .updateFeedState(newFeedState):
            state.feedState = newFeedState

            return .none
        }
    }

}
