import Foundation

struct AuthInfo: Codable {
    let login: String
    let password: String
    let accessToken: String
    let refreshToken: String
}

extension AuthInfo {
    var isValid: Bool {
        guard let expirationDate else {
            return false
        }

        return expirationDate > .now
    }

    var expirationDate: Date? {
        let components = accessToken.split(separator: ".")

        guard
            components.count == 3,
            let data: Data = .fromBase64(String(components[1])),
            let jsonObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
            let exp = jsonObject["exp"] as? TimeInterval
        else {
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }
}

// MARK: - Helpers

extension Data {

    fileprivate static func fromBase64(_ encoded: String) -> Data? {
        // Prefixes padding-character(s) (if needed).
        var encoded = encoded
        let remainder = encoded.count % 4

        if remainder > 0 {
            encoded = encoded.padding(
                toLength: encoded.count + 4 - remainder,
                withPad: "=",
                startingAt: 0
            )
        }

        // Finally, decode.
        return Data(base64Encoded: encoded)
    }

}
