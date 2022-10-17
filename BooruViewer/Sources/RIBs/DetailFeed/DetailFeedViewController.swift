import UIKit
import ModernRIBs
import sheets

protocol DetailFeedPresentableListener: AnyObject {
    func didDismissInteractively()
}

final class DetailFeedViewController: ScrollablePageViewController, DetailFeedPresentable, DetailFeedViewControllable {

    // MARK: - Internal Properties

    weak var listener: DetailFeedPresentableListener?

    // MARK: - Private Properties

    private var pages: [UIViewController] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        view.backgroundColor = .systemBackground
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isBeingDismissed else {
            return
        }

        listener?.didDismissInteractively()
    }

    // MARK: - ViewControllable

    func presentPostPages(_ pages: [ViewControllable], focusedPostIndex: Int) {
        self.pages = pages.map(\.uiviewController)

        setViewControllers(
            [self.pages[focusedPostIndex]],
            direction: .forward,
            animated: false
        )
    }

    func dismissPostPages() {
        pages = []
        setViewControllers([UIViewController()], direction: .forward, animated: false)
    }

}

// MARK: - UIPageViewControllerDataSource

extension DetailFeedViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }

        return (index > 0) ? pages[index - 1] : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }

        return (index < pages.count - 1) ? pages[index + 1] : nil
    }

}

extension DetailFeedViewController {

    static func make() -> DetailFeedViewController {
        .init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

}
