import ModernRIBs
import SankakuAPI

protocol DetailFeedInteractable: Interactable, DetailPageListener {
    var router: DetailFeedRouting? { get set }
    var listener: DetailFeedListener? { get set }
}

protocol DetailFeedViewControllable: ViewControllable {
    func presentPostPages(_ pages: [ViewControllable], focusedPostIndex: Int)
}

final class DetailFeedRouter: ViewableRouter<DetailFeedInteractable, DetailFeedViewControllable>, DetailFeedRouting {

    // MARK: - Private Properties

    private let detailPageBuilder: DetailPageBuildable
    private var detailPages: [ViewableRouting] = []

    // MARK: - Init

    init(interactor: DetailFeedInteractable,
         viewController: DetailFeedViewControllable,
         detailPageBuilder: DetailPageBuildable) {
        self.detailPageBuilder = detailPageBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - Routing

    func attachPostPages(for posts: [Post], focusedPostIndex: Int) {
        let detailPages = posts.map { post in
            detailPageBuilder.build(withListener: interactor, post: post)
        }

        self.detailPages = detailPages

        for detailPage in detailPages {
            attachChild(detailPage)
        }

        viewController.presentPostPages(detailPages.map(\.viewControllable), focusedPostIndex: focusedPostIndex)
    }

}
