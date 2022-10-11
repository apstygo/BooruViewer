import Foundation
import UIKit
import SankakuAPI

final class PostRepo: ObservableObject {

    // MARK: - Internal Types

    enum PostState {
        case loading
        case ready(UIImage)
        case failed
    }

    struct PostToken: Hashable {
        let id: Int
        let url: URL
    }

    struct PostViewModel {
        let id: Int
        let state: PostState
    }

    // MARK: - Internal Properties

    var posts: [PostViewModel] {
        postOrder.compactMap { PostViewModel(id: $0.id, state: postStates[$0] ?? .loading) }
    }

    // MARK: - Private Properties

    @Published private var postOrder: [PostToken] = []
    @Published private var postStates: [PostToken: PostState] = [:]

    // MARK: - Private Properties

    private let api = SankakuAPI()
    private let urlSession: URLSession = .shared

    // MARK: - Internal Methods

    func loadImages() async throws {
        let postsResponse = try await self.api.getPosts()

        let tokens: [PostToken] = postsResponse.data.compactMap { post -> PostToken? in
            guard let url = post.previewURL else {
                return nil
            }

            return PostToken(id: post.id, url: url)
        }

        await MainActor.run {
            postOrder = tokens

            for token in tokens {
                postStates[token] = .loading
            }
        }

        await withTaskGroup(of: Void.self) { group in
            for token in tokens {
                let request = URLRequest(url: token.url)

                do {
                    let (imageData, _) = try await urlSession.data(for: request)
                    let image = UIImage(data: imageData) ?? UIImage()

                    await MainActor.run {
                        postStates[token] = .ready(image)
                    }
                }
                catch {
                    await MainActor.run {
                        postStates[token] = .failed
                    }
                }
            }
        }
    }

}
