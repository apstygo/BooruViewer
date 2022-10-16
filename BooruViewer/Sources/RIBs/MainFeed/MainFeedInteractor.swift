import UIKit
import ModernRIBs
import SankakuAPI

protocol MainFeedRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

@MainActor
protocol MainFeedPresentable: Presentable {
    nonisolated var listener: MainFeedPresentableListener? { get set }

    func presentPosts(_ posts: [Post])
    func presentSuggestedTags(_ tags: [Tag])
    func clearSearchText()
    func presentSearchTags(_ tags: [Tag])
}

protocol MainFeedListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class MainFeedInteractor: PresentableInteractor<MainFeedPresentable>, MainFeedInteractable, MainFeedPresentableListener {

    // MARK: - Internal Properties

    weak var router: MainFeedRouting?
    weak var listener: MainFeedListener?

    // MARK: - Private Properties

    private let sankakuAPI: SankakuAPI
    private let feed: Feed

    private var searchTags: [Tag] = []
    private var updatePostsTask: Task<Void, Never>?
    private var suggestTagsTask: Task<Void, Error>?

    // MARK: - Init

    init(sankakuAPI: SankakuAPI,
         feed: Feed,
         presenter: MainFeedPresentable) {
        self.sankakuAPI = sankakuAPI
        self.feed = feed

        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecycle

    override func didBecomeActive() {
        super.didBecomeActive()

        startPostObserving()
    }

    override func willResignActive() {
        super.willResignActive()

        updatePostsTask?.cancel()
    }

    // MARK: - Presentable Listener

    func didShowCell(at indexPath: IndexPath) {
        feed.loadPage(forItemAt: indexPath.item)
    }

    func didUpdateSearch(withText searchText: String?, tags: [Tag]) {
        // Suggest new tags for search text

        suggestTagsTask?.cancel()

        suggestTagsTask = Task {
            guard let query = searchText, !query.isEmpty else {
                await presenter.presentSuggestedTags([])
                return
            }

            let tags = try await sankakuAPI.autoSuggestTags(for: query)
                .filter { tag in
                    !searchTags.contains { $0.name == tag.name }
                }

            await presenter.presentSuggestedTags(tags)
        }

        // Set current tags

        searchTags = tags
    }

    func didSelectTag(_ tag: Tag) {
        searchTags.append(tag)

        Task {
            await presenter.clearSearchText()
            await presenter.presentSearchTags(searchTags)
            await presenter.presentSuggestedTags([])
        }
    }

    // MARK: - Private Methods

    private func startPostObserving() {
        let postStream = feed.stateStream.map { $0.posts }

        updatePostsTask = Task {
            for await posts in postStream {
                await presenter.presentPosts(posts)
            }
        }

        feed.reload()
    }

}