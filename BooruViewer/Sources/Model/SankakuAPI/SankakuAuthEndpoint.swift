import Foundation
import Moya

enum SankakuAuthEndpoint {
    case authorize(login: String, password: String)
    case refreshAccessToken(refreshToken: String)
}

extension SankakuAuthEndpoint: TargetType {

    var baseURL: URL {
        SankakuEndpoint.baseURL
    }

    var path: String {
        "/auth/token"
    }

    var method: Moya.Method {
        .post
    }

    var task: Moya.Task {
        .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    var headers: [String: String]? {
        nil
    }

    private var parameters: [String: String] {
        switch self {
        case let .authorize(login, password):
            return [
                "login": login,
                "password": password
            ]

        case let .refreshAccessToken(refreshToken):
            return [
                "refresh_token": refreshToken
            ]
        }
    }

}
