import Foundation
import Combine
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

    private var disposeBag: [AnyCancellable] = []

    private var tags: [String] {
        guard let searchQuery else {
            return []
        }

        return searchQuery
            .split(separator: CharacterClass.whitespace)
            .map { String($0) }
    }

    // MARK: - Internal Methods

    func loadImages() {
        loadMore()
    }

    func loadMorePosts(for index: Int) {
        guard
            !isLoading,
            canLoadMore,
            postPreviews.count - index <= Constant.nextPageLoadRange
        else {
            return
        }

        isLoading = true
        loadMore()
    }

    func setSearchQuery(_ query: String) {
        searchQuery = query
        reload()
    }

    // MARK: - Private Methods

    private func reload() {
        // Cancel all running operations

        disposeBag.removeAll()

        // Reset State

        postPreviews = []
        nextPageId = nil
        canLoadMore = true
        isLoading = false

        // Reload

        loadMore()
    }

    private func loadMore() {
        api.getPosts(tags: tags,
                     limit: Constant.limit,
                     next: nextPageId)
            .receive(on: RunLoop.main)
            .sink { completion in
                // do nothing
            } receiveValue: { [self] response in
                nextPageId = response.meta.next
                canLoadMore = response.data.count >= Constant.limit

                let newPreviews = response.data.enumerated().map { index, post in
                    PostPreviewViewModel(index: postPreviews.count + index, post: post)
                }

                postPreviews.append(contentsOf: newPreviews)

                isLoading = false
            }
            .store(in: &disposeBag)
    }

}
