import Foundation

public struct PostsResponse: Decodable {
    public struct Meta: Decodable {
        public let next: String?
        public let prev: String?
    }

    public let meta: Meta
    public let data: [Post]
}
