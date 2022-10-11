import Foundation
import UIKit
import RegexBuilder
import SankakuAPI

struct PostPreviewViewModel {
    let index: Int
    let post: Post
}

final class PostRepo: ObservableObject {

    // MARK: - Private Types

    private enum Constant {
        static let limit = 50
        static let nextPageLoadRange = 25
    }

    // MARK: - Internal Properties

    @Published private(set) var postPreviews: [PostPreviewViewModel] = []

    // MARK: - Private Properties

    private let api = SankakuAPI()

    private var nextPageId: String?
    private var canLoadMore = true
    private var isLoading = false
    private var searchQuery: String?

    private var tags: [String] {
        guard let searchQuery else {
            return []
        }

        return searchQuery
            .split(separator: CharacterClass.whitespace)
            .map { String($0) }
    }

    // MARK: - Internal Methods

    func loadImages() async throws {
        try await loadMore()
    }

    func loadMorePosts(for index: Int) async throws {
        guard
            !isLoading,
            canLoadMore,
            postPreviews.count - index <= Constant.nextPageLoadRange
        else {
            return
        }

        isLoading = true

        try await loadMore()

        isLoading = false
    }

    func setSearchQuery(_ query: String) async throws {
        searchQuery = query
        try await reload()
    }

    // MARK: - Private Methods

    private func reload() async throws {
        postPreviews = []
        nextPageId = nil
        canLoadMore = true
        isLoading = false

        try await loadMore()
    }

    private func loadMore() async throws {
        let postsResponse = try await self.api.getPosts(
            tags: tags,
            limit: Constant.limit,
            next: nextPageId
        )

        nextPageId = postsResponse.meta.next
        canLoadMore = postsResponse.data.count >= Constant.limit

        let newPreviews = postsResponse.data.enumerated().map { index, post in
            PostPreviewViewModel(index: postPreviews.count + index, post: post)
        }

        await MainActor.run {
            postPreviews.append(contentsOf: newPreviews)
        }
    }

}
