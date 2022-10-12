import Foundation

public struct PostsResponse: Decodable, Equatable {
    public struct Meta: Decodable, Equatable {
        public let next: String?
        public let prev: String?
    }

    public let meta: Meta
    public let data: [Post]
}
