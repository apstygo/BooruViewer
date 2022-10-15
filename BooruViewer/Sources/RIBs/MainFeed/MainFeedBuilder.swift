//
//  MainFeedBuilder.swift
//  BooruViewer
//
//  Created by Artem Pstygo on 15.10.2022.
//

import ModernRIBs

protocol MainFeedDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class MainFeedComponent: Component<MainFeedDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol MainFeedBuildable: Buildable {
    func build(withListener listener: MainFeedListener) -> MainFeedRouting
}

final class MainFeedBuilder: Builder<MainFeedDependency>, MainFeedBuildable {

    override init(dependency: MainFeedDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MainFeedListener) -> MainFeedRouting {
        let component = MainFeedComponent(dependency: dependency)
        let viewController = MainFeedViewController()
        let interactor = MainFeedInteractor(presenter: viewController)
        interactor.listener = listener
        return MainFeedRouter(interactor: interactor, viewController: viewController)
    }
}
