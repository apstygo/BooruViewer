import Foundation

struct Request {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    var url: URL
    var method: Method
    var body: [String: Any] = [:]
    var params: [String: String] = [:]
    var headers: [String: String] = [:]
}
