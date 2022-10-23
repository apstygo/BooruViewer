import Foundation

struct AuthInfo: Codable {
    let login: String
    let password: String
    let accessToken: String
    let refreshToken: String
}
