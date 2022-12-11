import Foundation
import Moya

extension MoyaProvider {

    func request(_ target: Target) async throws -> Moya.Response {
        var cancellable: Cancellable?
        let onCancel = { cancellable?.cancel() }

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                cancellable = request(target) { result in
                    continuation.resume(with: result)
                }
            }
        } onCancel: {
            onCancel()
        }
    }

    func request<D: Decodable>(_ target: Target) async throws -> D {
        let moyaResponse = try await request(target)
        _ = try moyaResponse.filterSuccessfulStatusCodes()
        return try JSONDecoder().decode(D.self, from: moyaResponse.data)
    }

}
