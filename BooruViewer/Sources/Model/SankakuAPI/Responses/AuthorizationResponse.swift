import Foundation

public struct AuthorizationResponse: Decodable {
    public enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }

    public let tokenType: String
    public let accessToken: String
    public let refreshToken: String
}
