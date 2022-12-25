import ComposableArchitecture

struct FilterEditorFeature: ReducerProtocol {

    struct State: Equatable {
        var initialFilters: GetPostsFilters
        var filters: GetPostsFilters

        init(filters: GetPostsFilters) {
            self.initialFilters = filters
            self.filters = filters
        }

        var isApplyButtonActive: Bool {
            initialFilters != filters
        }
    }

    enum Action: Equatable {
        case apply

        case setFilters(GetPostsFilters)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .apply:
            // Handled by parent
            return .none

        case let .setFilters(newFilters):
            state.filters = newFilters

            return .none
        }
    }

}
