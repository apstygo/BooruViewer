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
        var response: PostsResponse = try await provider.request(.getPosts(configuration))

        #if SAFE_MODE
        response = adjustResponse(response)
        #endif

        return response
    }

    public func autoSuggestTags(for query: String) async throws -> [Tag] {
        try await provider.request(.autoSuggestTags(query: query))
    }

    #if SAFE_MODE
    private func adjustResponse(_ response: PostsResponse) -> PostsResponse {
        let adjustedPosts = response.data.map { post in
            Post(
                id: post.id,
                previewURL: flickrURL(id: post.id, size: (320, 180)),
                previewWidth: 320,
                previewHeight: 180,
                sampleURL: flickrURL(id: post.id, size: (1280, 720)),
                sampleWidth: 1280,
                sampleHeight: 720,
                fileURL: flickrURL(id: post.id, size: (1920, 1080)),
                width: 1920,
                height: 1080,
                tags: post.tags,
                source: post.source,
                fileType: .image(.jpeg)
            )
        }

        return PostsResponse(meta: response.meta, data: adjustedPosts)
    }

    private func flickrURL(id: Int, size: (Int, Int)) -> URL? {
        URL(string: "https://loremflickr.com/\(size.0)/\(size.1)?lock=\(id)")
    }
    #endif

}
