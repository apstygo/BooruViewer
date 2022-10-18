import ModernRIBs
import SankakuAPI

protocol DetailPageInteractable: Interactable, DetailFeedListener, MainFeedListener {
    var router: DetailPageRouting? { get set }
    var listener: DetailPageListener? { get set }
}

protocol DetailPageViewControllable: ViewControllable {
    func navigate(to viewController: ViewControllable)
    func pop(_ viewController: ViewControllable)
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

    func attachMainFeed(for tag: Tag) {
        let mainFeed = mainFeedBuilder.build(withListener: interactor, mode: .tag(tag))
        self.mainFeed = mainFeed

        attachChild(mainFeed)
        viewController.navigate(to: mainFeed.viewControllable)
    }

    func detachMainFeed() {
        guard let mainFeed else {
            return
        }

        viewController.pop(mainFeed.viewControllable)
        detachChild(mainFeed)
        self.mainFeed = nil
    }

}
