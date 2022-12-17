import SwiftUI
import ComposableArchitecture

struct LoginView: View {

    typealias ViewStore = ViewStoreOf<LoginFeature>

    let store: StoreOf<LoginFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(for: viewStore)
        }
    }

    func content(for viewStore: ViewStore) -> some View {
        VStack {
            textFields(for: viewStore)
            loginButton(for: viewStore)
        }
        .frame(maxWidth: 300)
        .animation(.default, value: viewStore.phase)
    }

    func textFields(for viewStore: ViewStore) -> some View {
        Group {
            TextField("Login", text: loginBinding(for: viewStore), prompt: Text("Login"))
                .textContentType(.username)

            SecureField(text: passwordBinding(for: viewStore)) {
                Text("Password")
            }
            .textContentType(.password)
        }
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .disabled(!viewStore.areTextFieldsEnabled)
    }

    func loginButton(for viewStore: ViewStore) -> some View {
        Button {
            viewStore.send(.login)
        } label: {
            loginButtonLabel(for: viewStore)
        }
        .disabled(!viewStore.isLoginButtonEnabled)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
    }

    @ViewBuilder func loginButtonLabel(for viewStore: ViewStore) -> some View {
        switch viewStore.phase {
        case .idle:
            Text("Login")

        case .loading:
            ProgressView()
        }
    }

    // MARK: - Bindings

    func loginBinding(for viewStore: ViewStore) -> Binding<String> {
        viewStore.binding { state in
            state.login
        } send: { newValue in
            .setLogin(newValue)
        }
    }

    func passwordBinding(for viewStore: ViewStore) -> Binding<String> {
        viewStore.binding { state in
            state.password
        } send: { newValue in
            .setPassword(newValue)
        }
    }

}

// MARK: - Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: Store(
                initialState: LoginFeature.State(),
                reducer: LoginFeature()
            )
        )
    }
}
