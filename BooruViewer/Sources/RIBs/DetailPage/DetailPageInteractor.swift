import Foundation
import Combine
import ModernRIBs
import SankakuAPI

protocol DetailPageRouting: ViewableRouting {
    func attachDetailFeed(for post: Post)
    func detachDetailFeed()
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

    private var postUpdateTask: Cancellable?
    private var didAppearOnce = false

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
        guard !didAppearOnce else {
            return
        }

        didAppearOnce = true
        startUpdates()
    }

    func didTapOnPost(_ post: Post) {
        router?.attachDetailFeed(for: post)
    }

    // MARK: - Private Methods

    private func present() {
        let viewModel = DetailPageViewModel(post: post, relatedPosts: [])
        presenter.viewModel = viewModel
    }

    private func startUpdates() {
        postUpdateTask = feed.statePublisher
            .map { [post] feedState in
                DetailPageViewModel(post: post, relatedPosts: feedState.posts)
            }
            .receive(on: RunLoop.main)
            .sink { [weak presenter] viewModel in
                presenter?.viewModel = viewModel
            }

        feed.customTags = ["recommended_for_post:\(post.id)"]
        feed.reload()
    }

}

// MARK: - DetailFeedListener

extension DetailPageInteractor: DetailFeedListener {

    func detailFeedDidDismiss() {
        router?.detachDetailFeed()
    }

}
