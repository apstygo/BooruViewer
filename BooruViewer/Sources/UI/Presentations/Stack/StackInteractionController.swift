import UIKit

final class StackInteractionController: UIPercentDrivenInteractiveTransition {

    // MARK: - Private Properties

    private weak var viewController: UIViewController!
    private var edgePan: UIGestureRecognizer!

    // MARK: - Init

    init(viewController: UIViewController) {
        self.viewController = viewController

        super.init()

        configureGestureRecognizers()
    }

    // MARK: - Private Methods

    private func configureGestureRecognizers() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        self.edgePan = edgePan
        edgePan.cancelsTouchesInView = false
        edgePan.edges = .left
        edgePan.delegate = self

        viewController.view.addGestureRecognizer(edgePan)
    }

    private func cleanup() {
        viewController.view.removeGestureRecognizer(edgePan)
    }

    @objc
    private func handleEdgePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: viewController.view.superview!).x
        let velocity = gestureRecognizer.velocity(in: viewController.view.superview!).x

        let totalDistance = viewController.view.superview!.bounds.width
        let progress = translation / totalDistance
        let projectedProgress = (translation + velocity) / totalDistance

        switch gestureRecognizer.state {
        case .began:
            viewController.dismiss(animated: true)

        case .changed:
            update(progress)

        case .cancelled, .ended:
            if projectedProgress >= 0.5 {
                cleanup()
                finish()
            }
            else {
                cancel()
            }

        default:
            // Do nothing
            break
        }
    }

}

// MARK: - UIGestureRecognizerDelegate

extension StackInteractionController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }

}
