import Foundation

extension URLSessionConfiguration {

    static var patient: URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity
        return configuration
    }

}
