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
