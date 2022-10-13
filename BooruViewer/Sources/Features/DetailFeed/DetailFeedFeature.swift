import ComposableArchitecture
import SankakuAPI

struct DetailFeedFeature: ReducerProtocol {

    struct State: Equatable {
        var post: Post?
    }

    enum Action: Equatable {

    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        return .none
    }

}
