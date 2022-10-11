import Foundation
import UIKit
import SankakuAPI

final class PostRepo: ObservableObject {

    // MARK: - Internal Properties

    @Published private(set) var posts: [Post] = []

    // MARK: - Private Properties

    private let api = SankakuAPI()

    // MARK: - Internal Methods

    func loadImages() async throws {
        let postsResponse = try await self.api.getPosts()

        await MainActor.run {
            posts = postsResponse.data
        }
    }

}
