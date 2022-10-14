import ComposableArchitecture
import SankakuAPI

struct DetailPageFeature: ReducerProtocol {

    struct State: Equatable {
        let post: Post
    }

    enum Action: Equatable {

    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        return .none
    }

}
