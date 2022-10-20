import ModernRIBs

protocol FilterEditorInteractable: Interactable {
    var router: FilterEditorRouting? { get set }
    var listener: FilterEditorListener? { get set }
}

protocol FilterEditorViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FilterEditorRouter: ViewableRouter<FilterEditorInteractable, FilterEditorViewControllable>, FilterEditorRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: FilterEditorInteractable, viewController: FilterEditorViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
