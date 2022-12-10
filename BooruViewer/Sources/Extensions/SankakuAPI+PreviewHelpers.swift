import SankakuAPI

extension SankakuAPI {

    static func getTopPost(tags: [String] = []) async throws -> Post {
        let response = try await SankakuAPI().getPosts(tags: tags)
        return response.data[0]
    }

}
