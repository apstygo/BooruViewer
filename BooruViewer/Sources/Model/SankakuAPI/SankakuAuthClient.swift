import Foundation
import Moya

protocol SankakuAuthClient: AnyObject {
    func request(_ endpoint: SankakuAuthEndpoint, completion: @escaping (Result<Data, Error>) -> Void)
}

extension SankakuAuthClient {

    func request<D>(_ endpoint: SankakuAuthEndpoint, completion: @escaping (Result<D, Error>) -> Void) where D: Decodable {
        request(endpoint) { result in
            switch result {
            case let .success(data):
                do {
                    let decodable = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(decodable))
                }
                catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func request(_ endpoint: SankakuAuthEndpoint) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            request(endpoint) { result in
                continuation.resume(with: result)
            }
        }
    }

    func request<D>(_ endpoint: SankakuAuthEndpoint) async throws -> D where D: Decodable {
        try await withCheckedThrowingContinuation { continuation in
            request(endpoint) { result in
                continuation.resume(with: result)
            }
        }
    }

}

final class SankakuAuthClientImpl: SankakuAuthClient {

    // MARK: - Private Properties

    private let provider: MoyaProvider<SankakuAuthEndpoint>

    // MARK: - Init

    init(provider: MoyaProvider<SankakuAuthEndpoint>) {
        self.provider = provider
    }

    // MARK: - Internal Methods

    func request(_ endpoint: SankakuAuthEndpoint, completion: @escaping (Result<Data, Error>) -> Void) {
        provider.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    completion(.success(response.data))
                }
                catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

}
