import Foundation

protocol AuthInfoStorage: AnyObject {
    var authInfo: AuthInfo? { get set }
}

final class AuthInfoDefaultsStorage: AuthInfoStorage {

    // MARK: - Private Types

    private enum Constant {
        static let key = "AuthInfoDefaultsStorage.authInfoKey"
    }

    // MARK: - Internal Properties

    var authInfo: AuthInfo? {
        get {
            getAuthInfo()
        }
        set {
            setAuthInfo(newValue)
        }
    }

    // MARK: - Private Properties

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Private Methods

    private func getAuthInfo() -> AuthInfo? {
        guard let string = defaults.string(forKey: Constant.key) else {
            return nil
        }

        let data = Data(string.utf8)
        return try? decoder.decode(AuthInfo.self, from: data)
    }

    private func setAuthInfo(_ authInfo: AuthInfo?) {
        guard let authInfo else {
            defaults.removeObject(forKey: Constant.key)
            return
        }

        guard
            let data = try? encoder.encode(authInfo),
            let string = String(data: data, encoding: .utf8)
        else {
            return
        }

        defaults.set(string, forKey: Constant.key)
    }

}

final class AuthInfoSecureStorage: AuthInfoStorage {

    // MARK: - Private Types

    private enum Constant {
        static let service = "sankaku"
    }

    private struct SensitiveData: Codable {
        let accessToken: String
        let refreshToken: String
    }

    // MARK: - Internal Properties

    var authInfo: AuthInfo? {
        get {
            getAuthInfo()
        }
        set {
            setAuthInfo(newValue)
        }
    }

    // MARK: - Private Properties

    private let secureStore: SecureStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init

    init(secureStore: SecureStore) {
        self.secureStore = secureStore
    }

    // MARK: - Private Methods

    private func getAuthInfo() -> AuthInfo? {
        guard
            let (login, data) = try? secureStore.getCredentials(forService: Constant.service),
            let sensitiveData = try? decoder.decode(SensitiveData.self, from: data)
        else {
            return nil
        }

        return AuthInfo(
            login: login,
            accessToken: sensitiveData.accessToken,
            refreshToken: sensitiveData.refreshToken
        )
    }

    private func setAuthInfo(_ authInfo: AuthInfo?) {
        guard let authInfo else {
            try? secureStore.setCredentials(nil, forService: Constant.service)
            return
        }

        let sensitiveData = SensitiveData(
            accessToken: authInfo.accessToken,
            refreshToken: authInfo.refreshToken
        )

        guard let data = try? encoder.encode(sensitiveData) else {
            return
        }

        try? secureStore.setCredentials((authInfo.login, data), forService: Constant.service)
    }

}
