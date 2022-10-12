import Foundation
import Combine
import SwiftJWT

public final class SankakuAPI {

    // MARK: - Private Properties

    private let urlSession: URLSession = .shared

    private var accessToken: String?

    private var accessTokenExpirationDate: Date? {
        get throws {
            guard let accessToken else {
                return nil
            }

            let jwt = try JWT<ClaimsStandardJWT>(jwtString: accessToken)
            return jwt.claims.exp
        }
    }

    // MARK: - Init

    public init() { /* Do nothing */ }

    // MARK: - Public Methods

    // TODO: Implement date filter
    public func getPosts(order: SortOrder = .date,
                         ratings: Set<Rating> = [.g],
                         hidePostsInBooks: HidePostsInBooks = .never,
                         mediaType: MediaType = .any,
                         mediaSize: MediaSize = .any,
                         tags: [String] = [],
                         ratingThreshold: Float = 0,
                         limit: Int = 40,
                         next: String? = nil,
                         prev: String? = nil) -> AnyPublisher<PostsResponse, Error> {
        var request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/posts/keyset")!,
            method: .get
        )

        // Tags

        var additionalTags = [
            "order:\(order.rawValue)"
        ]

        for rating in ratings {
            additionalTags.append("rating:\(rating.rawValue)")
        }

        if mediaType != .any {
            additionalTags.append("file_type:\(mediaType.rawValue)")
        }

        if mediaSize != .any {
            additionalTags.append("+\(mediaSize.rawValue)")
        }

        let allTags = tags + additionalTags

        // Params

        request.params = [
            "lang": "en",
            "limit": "\(limit)",
            "hide_posts_in_books": hidePostsInBooks.rawValue,
            "default_threshold": "\(ratingThreshold)",
            "tags": allTags.joined(separator: " ")
        ]

        if let next {
            request.params["next"] = next
        }

        if let prev {
            request.params["prev"] = prev
        }

        // Headers

        request.headers = [
            "dnd": "1",
            "origin": "https://beta.sankakucomplex.com",
            "referer": "https://beta.sankakucomplex.com/",
            "accept": "application/vnd.sankaku.api+json;v=2"
        ]

        return urlSession.executeRequest(
            request,
            ofType: PostsResponse.self
        )
    }

    public func autoSuggestTags(for query: String) -> AnyPublisher<[Tag], Error> {
        var request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/tags/autosuggestCreating")!,
            method: .get
        )

        request.params = [
            "tag": query
        ]

        return urlSession.executeRequest(request, ofType: [Tag].self)
    }

//    public func login(username: String, password: String) async throws {
//        var urlRequest = URLRequest(url: URL(string: "https://capi-v2.sankakucomplex.com/auth/token")!)
//        urlRequest.httpMethod = "POST"
//
//        let bodyString = "{ login: \(username), password: \(password) }"
//
//        urlRequest.httpBody = Data(bodyString.utf8)
//
//        let (data, response) = try await urlSession.data(for: urlRequest)
//    }

    // MARK: - Private Methods

//    private func processRequest() async throws -> (Data, URLResponse) {
//
//    }

}
