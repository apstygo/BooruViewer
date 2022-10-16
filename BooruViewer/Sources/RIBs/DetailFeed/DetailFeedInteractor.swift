import ModernRIBs

protocol DetailFeedRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DetailFeedPresentable: Presentable {
    var listener: DetailFeedPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DetailFeedListener: AnyObject {
    func detailFeedDidPop()
}

final class DetailFeedInteractor: PresentableInteractor<DetailFeedPresentable>, DetailFeedInteractable {

    // MARK: - Internal Properties

    weak var router: DetailFeedRouting?
    weak var listener: DetailFeedListener?

    // MARK: - Init

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DetailFeedPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecycle

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

}

// MARK: - DetailFeedPresentableListener

extension DetailFeedInteractor: DetailFeedPresentableListener {

    func didPop() {
        listener?.detailFeedDidPop()
    }

}
