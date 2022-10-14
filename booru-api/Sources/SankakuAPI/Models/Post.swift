import Foundation

public struct Post: Decodable, Hashable, Equatable, Identifiable {
    public enum CodingKeys: String, CodingKey {
        case id
        case previewURL = "preview_url"
        case sampleURL = "sample_url"
        case fileURL = "file_url"
        case tags
    }

    public let id: Int
    public let previewURL: URL?
    public let sampleURL: URL?
    public let fileURL: URL?
    public let tags: [Tag]
}
