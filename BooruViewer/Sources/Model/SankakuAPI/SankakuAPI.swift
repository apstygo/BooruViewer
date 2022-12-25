import Foundation
import Moya

public final class SankakuAPI {

    public struct NotImplementedError: Error { }

    // MARK: - Private Properties

    private let provider: MoyaProvider<SankakuAPITarget>

    // MARK: - Init

    public init(sessionConfiguration: URLSessionConfiguration = .af.default) {
        let session = Session(configuration: sessionConfiguration)
        self.provider = MoyaProvider(session: session)
    }

    // MARK: - Public Methods

    public func authorize(login: String, password: String) async throws -> AuthorizationResponse {
//        var request = Request(
//            url: URL(string: "https://capi-v2.sankakucomplex.com/auth/token")!,
//            method: .post
//        )
//
//        request.body = [
//            "login": login,
//            "password": password
//        ]
//
//        // Calling urlSession explicitly ensures no authorization is added to the request
//        return try await urlSession.executeRequest(request)

        throw NotImplementedError()
    }

    public func refreshAccessToken(withRefreshToken refreshToken: String) async throws -> AuthorizationResponse {
//        var request = Request(
//            url: URL(string: "https://capi-v2.sankakucomplex.com/auth/token")!,
//            method: .post
//        )
//
//        request.body = [
//            "refresh_token": refreshToken
//        ]
//
//        // Calling urlSession explicitly ensures no authorization is added to the request
//        return try await urlSession.executeRequest(request)

        throw NotImplementedError()
    }

    public func getPosts(
        filters: GetPostsFilters = .init(),
        tags: [String] = [],
        limit: Int = 40,
        next: String? = nil,
        prev: String? = nil
    ) async throws -> PostsResponse {
        let configuration = GetPostsConfiguration(
            filters: filters,
            tags: tags,
            limit: limit,
            next: next,
            prev: prev
        )

        return try await getPosts(configuration)
    }

    public func getPosts(_ configuration: GetPostsConfiguration) async throws -> PostsResponse {
        try await provider.request(.getPosts(configuration))
    }

    public func autoSuggestTags(for query: String) async throws -> [Tag] {
        try await provider.request(.autoSuggestTags(query: query))
    }

}
