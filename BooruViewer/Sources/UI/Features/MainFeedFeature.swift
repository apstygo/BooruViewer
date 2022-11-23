import ComposableArchitecture

struct MainFeedFeature: ReducerProtocol {

    struct State: Equatable { }
    enum Action: Equatable { }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }

}