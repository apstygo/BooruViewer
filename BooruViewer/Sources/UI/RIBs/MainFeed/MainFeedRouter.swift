import ModernRIBs
import SankakuAPI

protocol MainFeedInteractable: Interactable, DetailFeedListener, FilterEditorListener {
    var router: MainFeedRouting? { get set }
    var listener: MainFeedListener? { get set }
}

protocol MainFeedViewControllable: ViewControllable {
    func navigate(to viewController: ViewControllable)
    func pop(_ viewController: ViewControllable)

    func present(_ viewController: ViewControllable)
    func dismiss(_ viewController: ViewControllable)
}

final class MainFeedRouter: ViewableRouter<MainFeedInteractable, MainFeedViewControllable>, MainFeedRouting {

    // MARK: - Private Methods

    private let detailFeedBuilder: DetailFeedBuildable
    private let filterEditorBuilder: FilterEditorBuildable

    private var detailFeed: ViewableRouting?
    private var filterEditor: ViewableRouting?

    // MARK: - Init

    init(interactor: MainFeedInteractable,
         viewController: MainFeedViewControllable,
         detailFeedBuilder: DetailFeedBuildable,
         filterEditorBuilder: FilterEditorBuildable) {
        self.detailFeedBuilder = detailFeedBuilder
        self.filterEditorBuilder = filterEditorBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - Routing

    func attachDetailFeed(for post: Post) {
        let detailFeed = detailFeedBuilder.build(withListener: interactor, post: post)
        self.detailFeed = detailFeed

        attachChild(detailFeed)
        viewController.navigate(to: detailFeed.viewControllable)
    }

    func detachDetailFeed() {
        guard let detailFeed else {
            return
        }

        viewController.pop(detailFeed.viewControllable)
        detachChild(detailFeed)
        self.detailFeed = nil
    }

    func attachFilterEditor() {
        let filterEditor = filterEditorBuilder.build(withListener: interactor)
        self.filterEditor = filterEditor

        attachChild(filterEditor)
        viewController.present(filterEditor.viewControllable)
    }

    func detachFilterEditor() {
        guard let filterEditor else {
            return
        }

        viewController.dismiss(filterEditor.viewControllable)
        detachChild(filterEditor)
        self.filterEditor = nil
    }

}
