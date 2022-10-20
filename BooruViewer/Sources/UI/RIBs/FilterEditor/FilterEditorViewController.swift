import ModernRIBs
import UIKit

protocol FilterEditorPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class FilterEditorViewController: UIViewController, FilterEditorPresentable, FilterEditorViewControllable {

    weak var listener: FilterEditorPresentableListener?
}
