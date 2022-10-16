import ModernRIBs

protocol DetailFeedDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DetailFeedComponent: Component<DetailFeedDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DetailFeedBuildable: Buildable {
    func build(withListener listener: DetailFeedListener) -> DetailFeedRouting
}

final class DetailFeedBuilder: Builder<DetailFeedDependency>, DetailFeedBuildable {

    override init(dependency: DetailFeedDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailFeedListener) -> DetailFeedRouting {
        let component = DetailFeedComponent(dependency: dependency)
        let viewController = DetailFeedViewController()
        let interactor = DetailFeedInteractor(presenter: viewController)
        interactor.listener = listener
        return DetailFeedRouter(interactor: interactor, viewController: viewController)
    }
}
