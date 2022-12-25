import Foundation
import Moya

enum SankakuEndpoint {
    case getPosts(GetPostsConfiguration)
    case autoSuggestTags(query: String)
}

struct SankakuRequest {
    var endpoint: SankakuEndpoint
    var accessToken: String?
}

extension SankakuRequest: TargetType {

    var baseURL: URL {
        URL(string: "https://capi-v2.sankakucomplex.com")!
    }

    var path: String {
        switch endpoint {
        case .getPosts:
            return "/posts/keyset"

        case .autoSuggestTags:
            return "/tags/autosuggestCreating"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .getPosts, .autoSuggestTags:
            return .get
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case let .getPosts(configuration):
            return .requestParameters(parameters: configuration.params, encoding: URLEncoding.queryString)

        case let .autoSuggestTags(query):
            return .requestParameters(parameters: ["tag": query], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        guard let accessToken else {
            return nil
        }

        return ["Authorization": "Bearer \(accessToken)"]
    }

}
