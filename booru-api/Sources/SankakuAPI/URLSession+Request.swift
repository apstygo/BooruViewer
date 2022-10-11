import Foundation

extension URLSession {

    func executeRequest(_ request: Request) async throws -> (Data, HTTPURLResponse) {
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

        let (data, urlResponse) = try await data(for: urlRequest)
        return (data, urlResponse as! HTTPURLResponse)
    }

    func executeRequest<D: Decodable>(_ request: Request,
                                      ofType decodable: D.Type,
                                      decoder: JSONDecoder = JSONDecoder()) async throws -> (D, HTTPURLResponse) {
        let (data, response) = try await executeRequest(request)
        let decodable = try JSONDecoder().decode(decodable, from: data)
        return (decodable, response)
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
