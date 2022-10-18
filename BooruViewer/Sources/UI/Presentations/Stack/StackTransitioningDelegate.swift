import UIKit

final class StackTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private var interactionController: StackInteractionController?

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        StackAnimatedTransition(isForward: false)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        StackAnimatedTransition(isForward: true)
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        interactionController = StackInteractionController(viewController: presented)
        return nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }

}
