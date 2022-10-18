import ModernRIBs
import SankakuAPI

protocol DetailPageDependency: Dependency {
    var sankakuAPI: SankakuAPI { get }
}

final class DetailPageComponent: Component<DetailPageDependency>, DetailFeedDependency, MainFeedDependency {

    var sankakuAPI: SankakuAPI {
        dependency.sankakuAPI
    }

    var feed: Feed {
        shared { FeedImpl(sankakuAPI: dependency.sankakuAPI) }
    }

}

// MARK: - Builder

protocol DetailPageBuildable: Buildable {
    func build(withListener listener: DetailPageListener, post: Post) -> DetailPageRouting
}

final class DetailPageBuilder: Builder<DetailPageDependency>, DetailPageBuildable {

    override init(dependency: DetailPageDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailPageListener, post: Post) -> DetailPageRouting {
        let component = DetailPageComponent(dependency: dependency)
        let viewController = DetailPageViewController()

        let interactor = DetailPageInteractor(
            presenter: viewController,
            post: post,
            feed: component.feed
        )

        interactor.listener = listener

        let detailFeedBuilder = DetailFeedBuilder(dependency: component)
        let mainFeedBuilder = MainFeedBuilder(dependency: component)

        return DetailPageRouter(
            interactor: interactor,
            viewController: viewController,
            detailFeedBuilder: detailFeedBuilder,
            mainFeedBuilder: mainFeedBuilder
        )
    }
}
