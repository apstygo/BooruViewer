import ModernRIBs
import SankakuAPI

protocol DetailFeedRouting: ViewableRouting {
    func attachPostPages(for posts: [Post], focusedPostIndex: Int)
    func detachPostPages()
}

protocol DetailFeedPresentable: Presentable {
    var listener: DetailFeedPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DetailFeedListener: AnyObject {
    func detailFeedDidDismiss()
}

final class DetailFeedInteractor: PresentableInteractor<DetailFeedPresentable>, DetailFeedInteractable {

    // MARK: - Internal Properties

    weak var router: DetailFeedRouting?
    weak var listener: DetailFeedListener?

    // MARK: - Private Properties

    private let post: Post
    private let feed: Feed

    // MARK: - Init

    init(presenter: DetailFeedPresentable,
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

        attachPostPages()
    }

    override func willResignActive() {
        super.willResignActive()

        router?.detachPostPages()
    }

    // MARK: - Private Methods

    private func attachPostPages() {
        let posts = feed.state.posts
        let focusedPostIndex = posts.firstIndex(of: post) ?? 0

        router?.attachPostPages(for: posts, focusedPostIndex: focusedPostIndex)
    }

}

// MARK: - DetailFeedPresentableListener

extension DetailFeedInteractor: DetailFeedPresentableListener {

    func didDismissInteractively() {
        listener?.detailFeedDidDismiss()
    }

}
