import Foundation

extension URLSession {

    static var patient: URLSession {
        let configuration: URLSessionConfiguration = .default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity

        return URLSession(configuration: configuration)
    }

}
