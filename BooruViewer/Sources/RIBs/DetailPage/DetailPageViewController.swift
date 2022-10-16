import ModernRIBs
import UIKit

protocol DetailPagePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DetailPageViewController: UIViewController, DetailPagePresentable, DetailPageViewControllable {

    weak var listener: DetailPagePresentableListener?
}
