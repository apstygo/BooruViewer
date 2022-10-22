import Foundation
import Combine
import SwiftJWT

public final class SankakuAPI {

    // MARK: - Public Properties

    public var accessToken: String?

    // MARK: - Private Properties

    private let urlSession: URLSession

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

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Public Methods

    public func authorize(login: String, password: String) async throws -> AuthorizationResponse {
        var request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/auth/token")!,
            method: .post
        )

        request.body = [
            "login": login,
            "password": password
        ]

        let response: AuthorizationResponse = try await executeRequest(request)

        switch response {
        case let .success(success):
            accessToken = success.accessToken

        case .failure:
            // Do nothing
            break
        }

        return response
    }

    // TODO: Implement date filter
    public func getPosts(filters: GetPostsFilters = .init(),
                         tags: [String] = [],
                         limit: Int = 40,
                         next: String? = nil,
                         prev: String? = nil) async throws -> PostsResponse {
        var request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/posts/keyset")!,
            method: .get
        )

        // Tags

        let allTags = tags + filters.tags

        // Params

        request.params = [
            "lang": "en",
            "limit": "\(limit)",
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

        return try await executeRequest(request)
    }

    public func getPosts(recommendedFor postId: Int, limit: Int = 40) async throws -> [Post] {
        var request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/posts?tags=recommended_for_post:\(postId)")!,
            method: .get
        )

        request.params = [
            "tags": "recommended_for_post:\(postId)",
            "limit": "\(limit)"
        ]

        return try await executeRequest(request)
    }

    public func autoSuggestTags(for query: String) async throws -> [Tag] {
        var request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/tags/autosuggestCreating")!,
            method: .get
        )

        request.params = [
            "tag": query
        ]

        return try await executeRequest(request)
    }

    // MARK: - Private Methods

    private func executeRequest<D: Decodable>(_ request: Request) async throws -> D {
        var request = request

        if let accessToken {
            request.headers["authorization"] = "Bearer \(accessToken)"
        }

        return try await urlSession.executeRequest(request)
    }

}
