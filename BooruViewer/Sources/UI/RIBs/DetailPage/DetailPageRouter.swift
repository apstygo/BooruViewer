import ModernRIBs
import SankakuAPI

protocol DetailPageInteractable: Interactable, DetailFeedListener, MainFeedListener {
    var router: DetailPageRouting? { get set }
    var listener: DetailPageListener? { get set }
}

protocol DetailPageViewControllable: ViewControllable {
    func presentModally(_ viewController: ViewControllable, wrappingInNavigation: Bool)
    func dismissModal()
}

final class DetailPageRouter: ViewableRouter<DetailPageInteractable, DetailPageViewControllable>, DetailPageRouting {

    // MARK: - Private Properties

    private let detailFeedBuilder: DetailFeedBuildable
    private let mainFeedBuilder: MainFeedBuildable

    private var detailFeed: ViewableRouting?
    private var mainFeed: ViewableRouting?

    // MARK: - Init

    init(interactor: DetailPageInteractable,
         viewController: DetailPageViewControllable,
         detailFeedBuilder: DetailFeedBuildable,
         mainFeedBuilder: MainFeedBuildable) {
        self.detailFeedBuilder = detailFeedBuilder
        self.mainFeedBuilder = mainFeedBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - Routing

    func attachDetailFeed(for post: Post) {
        let detailFeed = detailFeedBuilder.build(withListener: interactor, post: post)
        self.detailFeed = detailFeed

        attachChild(detailFeed)
        viewController.presentModally(detailFeed.viewControllable, wrappingInNavigation: false)
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

    func attachMainFeed(for tag: Tag) {
        let mainFeed = mainFeedBuilder.build(withListener: interactor, mode: .tag(tag))
        self.mainFeed = mainFeed

        attachChild(mainFeed)
        viewController.presentModally(mainFeed.viewControllable, wrappingInNavigation: true)
    }

    func detachMainFeed() {
        guard let mainFeed else {
            return
        }

        if !mainFeed.viewControllable.uiviewController.isBeingDismissed {
            viewController.dismissModal()
        }

        detachChild(mainFeed)
        self.mainFeed = nil
    }

}
