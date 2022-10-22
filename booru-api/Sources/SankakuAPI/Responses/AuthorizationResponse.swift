import Foundation

public enum AuthorizationResponse: Decodable {
    public struct DecodingError: Error { }

    case success(AuthorizationSuccess)
    case failure(AuthorizationFailure)

    public init(from decoder: Decoder) throws {
        if let success = try? AuthorizationSuccess(from: decoder) {
            self = .success(success)
        }
        else if let failure = try? AuthorizationFailure(from: decoder) {
            self = .failure(failure)
        }
        else {
            throw DecodingError()
        }
    }
}

public struct AuthorizationSuccess: Decodable {
    public enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }

    public let tokenType: String
    public let accessToken: String
    public let refreshToken: String
}

public struct AuthorizationFailure: Decodable {
    public let error: String
}
