import ModernRIBs
import SankakuAPI

protocol DetailFeedDependency: Dependency {
    var feed: Feed { get }
}

final class DetailFeedComponent: Component<DetailFeedDependency>, DetailPageDependency {

    var feed: Feed {
        dependency.feed
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
        let viewController = DetailFeedViewController()

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
