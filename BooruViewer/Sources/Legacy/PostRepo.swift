import Foundation
import Combine
import SwiftUI
import RegexBuilder
import CombineExt
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
    @Published private(set) var tagSuggestions: [Tag] = []

    var searchQuery: Binding<String> {
        searchQueryRelay.binding
    }

    var tags: Binding<[Tag]> {
        tagRelay.binding
    }

    // MARK: - Private Properties

    private let api = SankakuAPI()

    private var nextPageId: String?
    private var canLoadMore = true
    private var isLoading = false
    private let searchQueryRelay = CurrentValueRelay("")
    private let tagRelay = CurrentValueRelay([Tag]())

    private var disposeBag: [AnyCancellable] = []

    // MARK: - Init

    init() {
        subscribe()
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

    func reload() {
        // Cancel all running operations

//        disposeBag.removeAll()

        // Reset State

        postPreviews = []
        nextPageId = nil
        canLoadMore = true
        isLoading = false

        // Reload

        loadMore()
    }

    // MARK: - Private Methods

    private func subscribe() {
        searchQueryRelay
//            .debounce(for: 2, scheduler: DispatchQueue.main)
            .flatMapLatest { [api] query in
                api.autoSuggestTags(for: query)
                    .replaceError(with: [])
            }
            .receive(on: RunLoop.main)
            .assign(to: \.tagSuggestions, on: self, ownership: .weak)
            .store(in: &disposeBag)
    }

    private func loadMore() {
        api.getPosts(tags: tagRelay.value.map(\.name),
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

// MARK: - Helpers

extension CurrentValueRelay {

    fileprivate var binding: Binding<Output> {
        Binding(get: { self.value }, set: { self.accept($0) })
    }

}
