import ModernRIBs
import SankakuAPI

protocol DetailPageRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DetailPagePresentable: Presentable {
    var listener: DetailPagePresentableListener? { get set }
    var viewModel: DetailPageViewModel? { get set }
}

protocol DetailPageListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class DetailPageInteractor: PresentableInteractor<DetailPagePresentable>, DetailPageInteractable, DetailPagePresentableListener {

    // MARK: - Internal Properties

    weak var router: DetailPageRouting?
    weak var listener: DetailPageListener?

    // MARK: - Private Properties

    private let post: Post
    private let feed: Feed

    private var postUpdateTask: Task<Void, Never>?

    // MARK: - Init

    init(presenter: DetailPagePresentable,
         post: Post,
         feed: Feed) {
        self.post = post
        self.feed = feed

        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecycle

    override func didBecomeActive() {
        super.didBecomeActive()

        present()
    }

    override func willResignActive() {
        super.willResignActive()

        postUpdateTask?.cancel()
        postUpdateTask = nil
    }

    // MARK: - PresentableListener

    func didScrollToRelatedPost(at index: Int) {
        feed.loadPage(forItemAt: index)
    }

    func willAppear() {
        startUpdates()
    }

    // MARK: - Private Methods

    private func present() {
        let viewModel = DetailPageViewModel(post: post, relatedPosts: [])
        presenter.viewModel = viewModel
    }

    private func startUpdates() {
        let postStream = feed.stateStream.map(\.posts)

        postUpdateTask = Task { [presenter, post] in
            for await posts in postStream {
                let viewModel = DetailPageViewModel(post: post, relatedPosts: posts)

                await MainActor.run {
                    presenter.viewModel = viewModel
                }
            }
        }

        feed.customTags = ["recommended_for_post:\(post.id)"]
        feed.reload()
    }

}
