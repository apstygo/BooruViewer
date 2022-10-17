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

    // MARK: - Init

    init(presenter: DetailPagePresentable, post: Post) {
        self.post = post

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
        // TODO: Pause any business logic.
    }

    // MARK: - Private Methods

    private func present() {
        let viewModel = DetailPageViewModel(post: post)
        presenter.viewModel = viewModel
    }

}
