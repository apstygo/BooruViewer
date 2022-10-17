import ModernRIBs
import SankakuAPI

protocol DetailPageDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DetailPageComponent: Component<DetailPageDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
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

        let interactor = DetailPageInteractor(presenter: viewController, post: post)
        interactor.listener = listener

        return DetailPageRouter(interactor: interactor, viewController: viewController)
    }
}