import Foundation
import Moya

protocol SankakuClient: AnyObject {
    func request(_ endpoint: SankakuEndpoint) async throws -> Data
}

extension SankakuClient {

    func request<D>(_ endpoint: SankakuEndpoint) async throws -> D where D: Decodable {
        let data = try await request(endpoint)
        return try JSONDecoder().decode(D.self, from: data)
    }

}

final class SankakuClientImpl: SankakuClient {

    // MARK: - Private Properties

    private let provider: MoyaProvider<SankakuRequest>
    private let accessTokenProvider: AccessTokenProvider

    private var isAuthorized: Bool {
        false
    }

    // MARK: - Init

    init(provider: MoyaProvider<SankakuRequest>, accessTokenProvider: AccessTokenProvider) {
        self.provider = provider
        self.accessTokenProvider = accessTokenProvider
    }

    // MARK: - Internal Methods

    func request(_ endpoint: SankakuEndpoint) async throws -> Data {
        var request = SankakuRequest(endpoint: endpoint)

        if isAuthorized {
            request.accessToken = try await accessTokenProvider.getValidAccessToken()
        }

        let response = try await provider.request(request).filterSuccessfulStatusCodes()
        return response.data
    }

}
