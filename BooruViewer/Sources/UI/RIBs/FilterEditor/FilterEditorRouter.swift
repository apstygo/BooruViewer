import ModernRIBs

protocol FilterEditorInteractable: Interactable {
    var router: FilterEditorRouting? { get set }
    var listener: FilterEditorListener? { get set }
}

final class FilterEditorRouter: ViewableRouter<FilterEditorInteractable, ViewControllable>, FilterEditorRouting {

    override init(interactor: FilterEditorInteractable, viewController: ViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

}
