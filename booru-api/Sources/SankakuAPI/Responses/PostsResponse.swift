import Foundation

public struct PostsResponse: Decodable {
    public struct Meta: Decodable {
        let next: String?
        let prev: String?
    }

    public struct Post: Decodable {
        let id: Int
        let previewUrl: URL
        let sampleUrl: URL
        let fileUrl: URL
    }

    let meta: Meta
    let data: [Post]
}
