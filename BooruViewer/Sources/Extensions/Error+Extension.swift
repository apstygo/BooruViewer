import Foundation
import Moya

extension Error {

    var httpStatusCode: Int? {
        guard let moyaError = self as? MoyaError else {
            return nil
        }

        switch moyaError {
        case let .statusCode(response):
            return response.statusCode

        default:
            return nil
        }
    }

    var isHTTPClientError: Bool {
        isHTTPStatusCodeError { (400..<500).contains($0) }
    }

    var isHTTPUnauthorizedError: Bool {
        isHTTPStatusCodeError { $0 == 401 }
    }

    func isHTTPStatusCodeError(matching predicate: (Int) -> Bool) -> Bool {
        guard let httpStatusCode else {
            return false
        }

        return predicate(httpStatusCode)
    }

}
