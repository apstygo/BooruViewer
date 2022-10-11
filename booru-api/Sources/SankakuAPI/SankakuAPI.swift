import Foundation
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

    public func getPosts() async throws -> PostsResponse {
        let request = Request(
            url: URL(string: "https://capi-v2.sankakucomplex.com/posts/keyset")!,
            method: .get
        )

        return try await urlSession.executeRequest(
            request,
            ofType: PostsResponse.self
        ).0
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
