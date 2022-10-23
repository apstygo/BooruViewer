import Foundation

struct AuthInfo: Codable {
    let accessToken: String
    let refreshToken: String
    let expirationDate: Date

    var isValid: Bool {
        expirationDate > .now
    }
}
