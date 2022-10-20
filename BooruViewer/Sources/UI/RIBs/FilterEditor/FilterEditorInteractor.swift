import ModernRIBs

protocol FilterEditorRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol FilterEditorPresentable: Presentable {
    var listener: FilterEditorPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol FilterEditorListener: AnyObject {
    func filterEditorDidFinish()
}

final class FilterEditorInteractor: PresentableInteractor<FilterEditorPresentable>, FilterEditorInteractable, FilterEditorPresentableListener {

    // MARK: - Internal Properties

    weak var router: FilterEditorRouting?
    weak var listener: FilterEditorListener?

    // MARK: - Init

    override init(presenter: FilterEditorPresentable) {
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

    // MARK: - PresentableListener

    func didDismiss() {
        listener?.filterEditorDidFinish()
    }

}
