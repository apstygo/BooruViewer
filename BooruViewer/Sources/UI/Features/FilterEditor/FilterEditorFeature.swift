import ComposableArchitecture
import SankakuAPI

struct FilterEditorFeature: ReducerProtocol {

    struct State: Equatable {
        var filters = GetPostsFilters()
    }

    enum Action: Equatable {
        case apply

        case setFilters(GetPostsFilters)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .apply:
            // TODO: Implement
            return .none

        case let .setFilters(newFilters):
            state.filters = newFilters

            return .none
        }
    }

}
