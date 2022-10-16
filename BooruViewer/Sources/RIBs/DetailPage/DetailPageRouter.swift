import ModernRIBs

protocol DetailPageInteractable: Interactable {
    var router: DetailPageRouting? { get set }
    var listener: DetailPageListener? { get set }
}

protocol DetailPageViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DetailPageRouter: ViewableRouter<DetailPageInteractable, DetailPageViewControllable>, DetailPageRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DetailPageInteractable, viewController: DetailPageViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
