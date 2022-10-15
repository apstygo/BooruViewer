//
//  MainFeedRouter.swift
//  BooruViewer
//
//  Created by Artem Pstygo on 15.10.2022.
//

import ModernRIBs

protocol MainFeedInteractable: Interactable {
    var router: MainFeedRouting? { get set }
    var listener: MainFeedListener? { get set }
}

protocol MainFeedViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MainFeedRouter: ViewableRouter<MainFeedInteractable, MainFeedViewControllable>, MainFeedRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: MainFeedInteractable, viewController: MainFeedViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
