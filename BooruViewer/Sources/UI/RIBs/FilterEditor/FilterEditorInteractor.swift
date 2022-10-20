import ModernRIBs

protocol FilterEditorRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol FilterEditorPresentable: Presentable {
    var listener: FilterEditorPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol FilterEditorListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class FilterEditorInteractor: PresentableInteractor<FilterEditorPresentable>, FilterEditorInteractable, FilterEditorPresentableListener {

    weak var router: FilterEditorRouting?
    weak var listener: FilterEditorListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: FilterEditorPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
