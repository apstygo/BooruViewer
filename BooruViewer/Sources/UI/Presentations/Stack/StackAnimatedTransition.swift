import UIKit

final class StackAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Private Properties

    private let isForward: Bool

    // MARK: - Init

    init(isForward: Bool) {
        self.isForward = isForward
        super.init()
    }

    // MARK: - Internal Methods

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedVC = transitionContext.viewController(forKey: isForward ? .to : .from),
            let presentingVC = transitionContext.viewController(forKey: isForward ? .from : .to)
        else {
            return
        }

        if isForward {
            transitionContext.containerView.addSubview(presentedVC.view)
        }

        let internalFrame = presentingVC.view.bounds
        var outOfBoundsFrame = internalFrame
        outOfBoundsFrame.origin.x = outOfBoundsFrame.width

        let startingFrame = isForward ? outOfBoundsFrame : internalFrame
        let finalFrame = isForward ? internalFrame : outOfBoundsFrame

        if isForward {
            presentedVC.view.frame = startingFrame
        }

        let duration = transitionContext.isAnimated ? transitionDuration(using: transitionContext) : 0
        let options: UIView.AnimationOptions = transitionContext.isInteractive ? .curveLinear : .curveEaseOut

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            presentedVC.view.frame = finalFrame
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }

}
