import Foundation
import Combine

extension URLSession {

    func executeRequest(_ request: Request) -> URLSession.DataTaskPublisher {
        var headers = request.headers

        var urlRequest = URLRequest(url: request.url.addingQueryParameters(request.params))
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

        return dataTaskPublisher(for: urlRequest)
    }

    func executeRequest<D: Decodable>(_ request: Request, ofType decodable: D.Type) -> AnyPublisher<D, Error> {
        executeRequest(request)
            .map(\.data)
            .decode(type: decodable, decoder: JSONDecoder())
            .eraseToAnyPublisher()
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
