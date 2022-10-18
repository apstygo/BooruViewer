import ModernRIBs
import UIKit

protocol RootPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class RootViewController: UIViewController, RootPresentable {

    weak var listener: RootPresentableListener?

}

extension RootViewController: RootViewControllable {

    func presentInNavigationStack(_ viewController: ModernRIBs.ViewControllable) {
        let navigationController = UINavigationController(rootViewController: viewController.uiviewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
    }

}
