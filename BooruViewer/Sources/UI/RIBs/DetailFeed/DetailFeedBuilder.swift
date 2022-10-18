import ModernRIBs
import SankakuAPI

protocol DetailFeedDependency: Dependency {
    var feed: Feed { get }
    var sankakuAPI: SankakuAPI { get }
}

final class DetailFeedComponent: Component<DetailFeedDependency>, DetailPageDependency {

    var feed: Feed {
        dependency.feed
    }

    var sankakuAPI: SankakuAPI {
        dependency.sankakuAPI
    }

}

// MARK: - Builder

protocol DetailFeedBuildable: Buildable {
    func build(withListener listener: DetailFeedListener, post: Post) -> DetailFeedRouting
}

final class DetailFeedBuilder: Builder<DetailFeedDependency>, DetailFeedBuildable {

    override init(dependency: DetailFeedDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailFeedListener, post: Post) -> DetailFeedRouting {
        let component = DetailFeedComponent(dependency: dependency)
        let viewController: DetailFeedViewController = .make()

        let interactor = DetailFeedInteractor(
            presenter: viewController,
            post: post,
            feed: component.feed
        )

        interactor.listener = listener

        let detailPageBuilder = DetailPageBuilder(dependency: component)

        return DetailFeedRouter(
            interactor: interactor,
            viewController: viewController,
            detailPageBuilder: detailPageBuilder
        )
    }
}
