import Foundation

enum SecureStoreError: Error {
    case saveError(OSStatus)
    case updateError(OSStatus)
    case getError(OSStatus)
    case deleteError(OSStatus)
    case unexpectedPasswordData
}

protocol SecureStore: AnyObject {
    typealias Credentials = (account: String, data: Data)

    func setCredentials(_ credentials: Credentials?, forService service: String) throws
    func getCredentials(forService service: String) throws -> Credentials?
}

final class SecureKeychainStore: SecureStore {

    // MARK: - Internal Methods

    func setCredentials(_ credentials: Credentials?, forService service: String) throws {
        guard let credentials else {
            try deleteCredentials(forService: service)
            return
        }

        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: credentials.account,
            kSecValueData: credentials.data
        ] as CFDictionary

        let status = SecItemAdd(query, nil)

        if status != errSecSuccess {
            throw SecureStoreError.saveError(status)
        }

        switch status {
        case errSecSuccess:
            // Do nothing
            break

        case errSecDuplicateItem:
            try updateCredentials(credentials, forService: service)

        default:
            throw SecureStoreError.saveError(status)
        }
    }

    func getCredentials(forService service: String) throws -> Credentials? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)

        switch status {
        case errSecItemNotFound:
            return nil

        case errSecSuccess:
            return try extractCredentials(fromResult: result)

        default:
            throw SecureStoreError.getError(status)
        }
    }

    // MARK: - Private Methods

    private func updateCredentials(_ credentials: Credentials, forService service: String) throws {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: credentials.account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        let attributesToUpdate = [kSecValueData: credentials.data] as CFDictionary
        let status = SecItemUpdate(query, attributesToUpdate)

        if status != errSecSuccess {
            throw SecureStoreError.updateError(status)
        }
    }

    private func extractCredentials(fromResult result: CFTypeRef?) throws -> Credentials {
        guard
            let item = result as? [String: Any],
            let data = item[kSecValueData as String] as? Data,
            let account = item[kSecAttrAccount as String] as? String
        else {
            throw SecureStoreError.unexpectedPasswordData
        }

        return (account, data)
    }

    private func deleteCredentials(forService service: String) throws {
        let query = [
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        let status = SecItemDelete(query)

        switch status {
        case errSecSuccess, errSecItemNotFound:
            // Do nothing
            break

        default:
            throw SecureStoreError.deleteError(status)
        }
    }

}
