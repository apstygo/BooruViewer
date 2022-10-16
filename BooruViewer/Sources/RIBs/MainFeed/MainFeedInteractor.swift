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
}

protocol MainFeedListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class MainFeedInteractor: PresentableInteractor<MainFeedPresentable>, MainFeedInteractable, MainFeedPresentableListener {

    // MARK: - Private Properties

    private enum Constant {
        static let loadThreshold = 25
    }

    // MARK: - Internal Properties

    weak var router: MainFeedRouting?
    weak var listener: MainFeedListener?

    // MARK: - Private Properties

    private let sankakuAPI: SankakuAPI
    private let feedManager: FeedManager

    private var posts: [Post] = [] {
        didSet {
            Task {
                await presenter.presentPosts(posts)
            }
        }
    }

    // MARK: - Init

    init(sankakuAPI: SankakuAPI,
         feedManager: FeedManager,
         presenter: MainFeedPresentable) {
        self.sankakuAPI = sankakuAPI
        self.feedManager = feedManager

        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecycle

    override func didBecomeActive() {
        super.didBecomeActive()

        loadPosts()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    // MARK: - Presentable Listener

    func didShowCell(at indexPath: IndexPath) {
        guard posts.count - indexPath.item == Constant.loadThreshold else {
            return
        }

        loadPosts()
    }

    // MARK: - Private Methods

    private func loadPosts() {
        Task {
            await feedManager.loadNextPage()
            posts = await feedManager.posts
        }
    }

}
