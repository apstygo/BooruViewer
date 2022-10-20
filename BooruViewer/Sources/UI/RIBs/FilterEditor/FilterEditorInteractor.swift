import ModernRIBs
import SankakuAPI

protocol FilterEditorRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol FilterEditorPresentable: Presentable {
    var listener: FilterEditorPresentableListener? { get set }

    func presentFilters(_ filters: GetPostsFilters)
}

protocol FilterEditorListener: AnyObject {
    func filterEditorDidFinish(with filters: GetPostsFilters?)
}

final class FilterEditorInteractor: PresentableInteractor<FilterEditorPresentable>, FilterEditorInteractable, FilterEditorPresentableListener {

    // MARK: - Internal Properties

    weak var router: FilterEditorRouting?
    weak var listener: FilterEditorListener?

    // MARK: - Private Properties

    private var filters: GetPostsFilters

    // MARK: - Init

    init(presenter: FilterEditorPresentable, filters: GetPostsFilters) {
        self.filters = filters

        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecycle

    override func didBecomeActive() {
        super.didBecomeActive()

        presenter.presentFilters(filters)
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    // MARK: - PresentableListener

    func didUpdateFilters(_ newFilters: GetPostsFilters) {
        filters = newFilters
    }

    func didDismiss() {
        listener?.filterEditorDidFinish(with: nil)
    }

    func didApply() {
        listener?.filterEditorDidFinish(with: filters)
    }

}
