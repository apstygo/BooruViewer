import Foundation
import ModernRIBs
import SankakuAPI

protocol MainFeedDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class MainFeedComponent: Component<MainFeedDependency>, DetailFeedDependency, FilterEditorDependency {

    var urlSession: URLSession {
        shared {
            let configuration: URLSessionConfiguration = .default
            configuration.waitsForConnectivity = true
            configuration.timeoutIntervalForRequest = .infinity
            configuration.timeoutIntervalForResource = .infinity
            return URLSession(configuration: configuration)
        }
    }

    var sankakuAPI: SankakuAPI {
        shared { SankakuAPI(urlSession: urlSession) }
    }

    var feed: Feed {
        shared { FeedImpl(sankakuAPI: sankakuAPI) }
    }

}

// MARK: - Builder

protocol MainFeedBuildable: Buildable {
    func build(withListener listener: MainFeedListener, mode: MainFeedMode) -> MainFeedRouting
}

final class MainFeedBuilder: Builder<MainFeedDependency>, MainFeedBuildable {

    override init(dependency: MainFeedDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MainFeedListener, mode: MainFeedMode) -> MainFeedRouting {
        let component = MainFeedComponent(dependency: dependency)
        let viewController = MainFeedViewController()

        let interactor = MainFeedInteractor(
            sankakuAPI: component.sankakuAPI,
            feed: component.feed,
            mode: mode,
            presenter: viewController
        )

        interactor.listener = listener

        let detailFeedBuilder = DetailFeedBuilder(dependency: component)
        let filterEditorBuilder = FilterEditorBuilder(dependency: component)

        return MainFeedRouter(
            interactor: interactor,
            viewController: viewController,
            detailFeedBuilder: detailFeedBuilder,
            filterEditorBuilder: filterEditorBuilder
        )
    }
}
