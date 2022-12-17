import ComposableArchitecture

struct LoginFeature: ReducerProtocol {

    struct State: Equatable {
        enum Phase: Equatable {
            case idle
            case loading
        }

        var login = ""
        var password = ""
        var phase: Phase = .idle

        var isLoginButtonEnabled: Bool {
            login.count >= 3 && password.count >= 3 && phase == .idle
        }

        var areTextFieldsEnabled: Bool {
            phase == .idle
        }
    }

    enum Action {
        case login
        case setLogin(String)
        case setPassword(String)

        case handleLoginResult(Bool)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .login:
            state.phase = .loading

            return .task {
                try await Task.sleep(for: .seconds(2))
                return .handleLoginResult(true)
            }

        case let .setLogin(newLogin):
            state.login = newLogin

            return .none

        case let .setPassword(newPassword):
            state.password = newPassword

            return .none

        case let .handleLoginResult(result):
            state.login = ""
            state.password = ""
            state.phase = .idle

            return .none
        }
    }

}
