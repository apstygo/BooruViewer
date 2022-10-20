import ModernRIBs
import SankakuAPI

protocol FilterEditorDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class FilterEditorComponent: Component<FilterEditorDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol FilterEditorBuildable: Buildable {
    func build(withListener listener: FilterEditorListener, filters: GetPostsFilters) -> FilterEditorRouting
}

final class FilterEditorBuilder: Builder<FilterEditorDependency>, FilterEditorBuildable {

    override init(dependency: FilterEditorDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: FilterEditorListener, filters: GetPostsFilters) -> FilterEditorRouting {
        let component = FilterEditorComponent(dependency: dependency)

        let viewController = FilterEditorViewController()

        let interactor = FilterEditorInteractor(presenter: viewController, filters: filters)
        interactor.listener = listener

        return FilterEditorRouter(interactor: interactor, viewController: viewController)
    }
}
