import ModernRIBs
import SankakuAPI

protocol MainFeedDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class MainFeedComponent: Component<MainFeedDependency> {

    var sankakuAPI: SankakuAPI {
        shared { SankakuAPI() }
    }

    var feed: Feed {
        shared { FeedImpl(sankakuAPI: sankakuAPI) }
    }

}

// MARK: - Builder

protocol MainFeedBuildable: Buildable {
    func build(withListener listener: MainFeedListener) -> MainFeedRouting
}

final class MainFeedBuilder: Builder<MainFeedDependency>, MainFeedBuildable {

    override init(dependency: MainFeedDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MainFeedListener) -> MainFeedRouting {
        let component = MainFeedComponent(dependency: dependency)
        let viewController = MainFeedViewController()

        let interactor = MainFeedInteractor(
            sankakuAPI: component.sankakuAPI,
            feed: component.feed,
            presenter: viewController
        )

        interactor.listener = listener

        return MainFeedRouter(interactor: interactor, viewController: viewController)
    }
}
