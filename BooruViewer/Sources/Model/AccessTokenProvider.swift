import Foundation

enum AccessTokenProviderError: Error {
    case missingAuthorization
}

protocol AccessTokenProvider {
    func getValidAccessToken(completion: @escaping (Result<String, Error>) -> Void)
}

extension AccessTokenProvider {

    func getValidAccessToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            getValidAccessToken { result in
                continuation.resume(with: result)
            }
        }
    }

}

final class AccessTokenProviderImpl: AccessTokenProvider {

    // MARK: - Private Properties

    private let sankakuAuthClient: SankakuAuthClient
    private let authInfoStorage: AuthInfoStorage

    private let queue = DispatchQueue(label: "AccessTokenProviderImpl", qos: .userInteractive)
    private let semaphore = DispatchSemaphore(value: 1)

    // MARK: - Init

    init(sankakuAuthClient: SankakuAuthClient, authInfoStorage: AuthInfoStorage) {
        self.sankakuAuthClient = sankakuAuthClient
        self.authInfoStorage = authInfoStorage
    }

    // MARK: - Internal Methods

    func getValidAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        queue.async {
            self._getValidAccessToken(completion: completion)
        }
    }

    // MARK: - Private Methods

    private func _getValidAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        semaphore.wait()

        guard let authInfo = authInfoStorage.authInfo else {
            semaphore.signal()
            completion(.failure(AccessTokenProviderError.missingAuthorization))
            return
        }

        guard !authInfo.isValid else {
            semaphore.signal()
            completion(.success(authInfo.accessToken))
            return
        }

        refreshAccessToken(withRefreshToken: authInfo.refreshToken) { [self] result in
            switch result {
            case let .success(authResponse):
                let newAuthInfo = AuthInfo(
                    login: authInfo.login,
                    accessToken: authResponse.accessToken,
                    refreshToken: authResponse.refreshToken
                )

                authInfoStorage.authInfo = newAuthInfo

                semaphore.signal()
                completion(.success(authResponse.accessToken))

            case let .failure(error):
                if error.isHTTPClientError {
                    authInfoStorage.authInfo = nil
                }

                semaphore.signal()
                completion(.failure(error))
            }
        }
    }

    private func refreshAccessToken(
        withRefreshToken refreshToken: String,
        completion: @escaping (Result<AuthorizationResponse, Error>) -> Void
    ) {
        let endpoint: SankakuAuthEndpoint = .refreshAccessToken(refreshToken: refreshToken)
        sankakuAuthClient.request(endpoint, completion: completion)
    }

}
