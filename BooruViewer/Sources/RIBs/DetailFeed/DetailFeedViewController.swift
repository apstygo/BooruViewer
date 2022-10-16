import UIKit
import ModernRIBs

protocol DetailFeedPresentableListener: AnyObject {
    func didPop()
}

final class DetailFeedViewController: UIViewController, DetailFeedPresentable, DetailFeedViewControllable {

    // MARK: - Internal Properties

    weak var listener: DetailFeedPresentableListener?

    // MARK: - Private Properties

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pages: [UIViewController] = []

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()

        embed(pageViewController)
        pageViewController.dataSource = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isMovingFromParent else {
            return
        }

        listener?.didPop()
    }

    // MARK: - ViewControllable

    func presentPostPages(_ pages: [ViewControllable], focusedPostIndex: Int) {
        self.pages = pages.map(\.uiviewController)

        pageViewController.setViewControllers(
            [self.pages[focusedPostIndex]],
            direction: .forward,
            animated: false
        )
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
