import ModernRIBs
import SankakuAPI

protocol DetailPageInteractable: Interactable, DetailFeedListener {
    var router: DetailPageRouting? { get set }
    var listener: DetailPageListener? { get set }
}

protocol DetailPageViewControllable: ViewControllable {
    func presentModally(_ viewController: ViewControllable)
    func dismissModal()
}

final class DetailPageRouter: ViewableRouter<DetailPageInteractable, DetailPageViewControllable>, DetailPageRouting {

    // MARK: - Private Properties

    private let detailFeedBuilder: DetailFeedBuildable

    private var detailFeed: ViewableRouting?

    // MARK: - Init

    init(interactor: DetailPageInteractable,
         viewController: DetailPageViewControllable,
         detailFeedBuilder: DetailFeedBuildable) {
        self.detailFeedBuilder = detailFeedBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - Routing

    func attachDetailFeed(for post: Post) {
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
