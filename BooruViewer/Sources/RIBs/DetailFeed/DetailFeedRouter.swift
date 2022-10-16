import ModernRIBs

protocol DetailFeedInteractable: Interactable {
    var router: DetailFeedRouting? { get set }
    var listener: DetailFeedListener? { get set }
}

protocol DetailFeedViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DetailFeedRouter: ViewableRouter<DetailFeedInteractable, DetailFeedViewControllable>, DetailFeedRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DetailFeedInteractable, viewController: DetailFeedViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
