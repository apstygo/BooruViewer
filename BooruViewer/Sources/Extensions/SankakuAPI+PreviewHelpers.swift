import SankakuAPI

extension SankakuAPI {

    static func getTopPost() async throws -> Post {
        let response = try await SankakuAPI().getPosts()
        return response.data[0]
    }

}
