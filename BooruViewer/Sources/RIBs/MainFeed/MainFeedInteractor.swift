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

    // MARK: - Internal Properties

    weak var router: MainFeedRouting?
    weak var listener: MainFeedListener?

    // MARK: - Private Properties

    private let sankakuAPI: SankakuAPI

    // MARK: - Init

    init(sankakuAPI: SankakuAPI, presenter: MainFeedPresentable) {
        self.sankakuAPI = sankakuAPI

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

    // MARK: - Private Methods

    private func loadPosts() {
        Task {
            let postsResponse = try await sankakuAPI.getPosts()
            await presenter.presentPosts(postsResponse.data)
        }
    }

}
