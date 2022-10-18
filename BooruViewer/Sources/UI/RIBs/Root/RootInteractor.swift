import ModernRIBs

protocol RootRouting: ViewableRouting {
    func routeToMainFeed()
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {

    weak var router: RootRouting?

    // MARK: - Init

    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecyclt

    override func didBecomeActive() {
        super.didBecomeActive()

        router?.routeToMainFeed()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

}

// MARK: - MainFeedListener

extension RootInteractor: MainFeedListener {

    func mainFeedDidDismiss() {
        // Do nothing
    }

}
