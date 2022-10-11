import Foundation

public struct PostsResponse: Decodable {
    public struct Meta: Decodable {
        public let next: String?
        public let prev: String?
    }

    public struct Post: Decodable {
        public enum CodingKeys: String, CodingKey {
            case id
            case previewURL = "preview_url"
            case sampleURL = "sample_url"
            case fileURL = "file_url"
        }

        public let id: Int
        public let previewURL: URL?
        public let sampleURL: URL?
        public let fileURL: URL?
    }

    public let meta: Meta
    public let data: [Post]
}
