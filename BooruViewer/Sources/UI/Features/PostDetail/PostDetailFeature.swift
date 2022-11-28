import ComposableArchitecture
import SankakuAPI

struct PostDetailFeature: ReducerProtocol {

    struct State: Equatable {
        let post: Post
    }

    enum Action: Equatable {

    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }

}
