import Foundation
import Moya

enum SankakuAPITarget: TargetType {

    case getPosts(GetPostsConfiguration)
    case autoSuggestTags(query: String)

    var baseURL: URL {
        URL(string: "https://capi-v2.sankakucomplex.com")!
    }

    var path: String {
        switch self {
        case .getPosts:
            return "/posts/keyset"

        case .autoSuggestTags:
            return "/tags/autosuggestCreating"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPosts, .autoSuggestTags:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getPosts(configuration):
            return .requestParameters(parameters: configuration.params, encoding: URLEncoding.queryString)

        case let .autoSuggestTags(query):
            return .requestParameters(parameters: ["tag": query], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        nil
    }

}
