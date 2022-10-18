import ModernRIBs

protocol RootInteractable: Interactable, MainFeedListener {
    var router: RootRouting? { get set }
}

protocol RootViewControllable: ViewControllable {
    func presentInNavigationStack(_ viewController: ViewControllable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {

    // MARK: - Private Properties

    private let mainFeedBuilder: MainFeedBuildable

    private var mainFeed: ViewableRouting?

    // MARK: - Init

    init(interactor: RootInteractable,
         viewController: RootViewControllable,
         mainFeedBuilder: MainFeedBuildable) {
        self.mainFeedBuilder = mainFeedBuilder

        super.init(interactor: interactor, viewController: viewController)

        interactor.router = self
    }

    // MARK: - Internal Methods

    func routeToMainFeed() {
        let mainFeed = mainFeedBuilder.build(withListener: interactor, mode: .primary)
        self.mainFeed = mainFeed

        attachChild(mainFeed)
        viewController.presentInNavigationStack(mainFeed.viewControllable)
    }

}
