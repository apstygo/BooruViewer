import ModernRIBs
import SankakuAPI

protocol MainFeedInteractable: Interactable, DetailFeedListener {
    var router: MainFeedRouting? { get set }
    var listener: MainFeedListener? { get set }
}

protocol MainFeedViewControllable: ViewControllable {
    func presentModally(_ viewController: ViewControllable)
    func dismissModal()
}

final class MainFeedRouter: ViewableRouter<MainFeedInteractable, MainFeedViewControllable>, MainFeedRouting {

    // MARK: - Private Methods

    private let detailFeedBuilder: DetailFeedBuildable

    private var detailFeed: ViewableRouting?

    // MARK: - Init

    init(interactor: MainFeedInteractable,
         viewController: MainFeedViewControllable,
         detailFeedBuilder: DetailFeedBuildable) {
        self.detailFeedBuilder = detailFeedBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - Routing

    func routeToDetailFeed(for post: Post) {
        let detailFeed = detailFeedBuilder.build(withListener: interactor, post: post)
        self.detailFeed = detailFeed

        attachChild(detailFeed)
        viewController.presentModally(detailFeed.viewControllable)
    }

    func detachDetailFeed() {
        guard let detailFeed else {
            return
        }

        if !detailFeed.viewControllable.uiviewController.isBeingDismissed {
            viewController.dismissModal()
        }

        detachChild(detailFeed)
        self.detailFeed = nil
    }

}
