import Foundation
import Combine

extension URLSession {

    enum RequestError: Error {
        case badResponseCode(Int)
    }

    func executeRequest(_ request: Request) async throws -> Data {
        var headers = request.headers

        let url = request.url.addingQueryParameters(request.params)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        // Body

        if !request.body.isEmpty, let data = try? JSONSerialization.data(withJSONObject: request.body) {
            headers["Content-Type"] = "application/json"
            urlRequest.httpBody = data
        }

        // Headers

        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Process the response

        let (data, urlResponse) = try await data(for: urlRequest)

        if let httpResponse = urlResponse as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw RequestError.badResponseCode(httpResponse.statusCode)
        }

        return data
    }

    func executeRequest<D: Decodable>(_ request: Request) async throws -> D {
        let data = try await executeRequest(request)
        return try JSONDecoder().decode(D.self, from: data)
    }

}

// MARK: - Helpers

extension URL {

    fileprivate func addingQueryParameters(_ parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        return components.url ?? self
    }

}
