import ModernRIBs
import UIKit

protocol DetailPagePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DetailPageViewController: UIViewController, DetailPagePresentable, DetailPageViewControllable {

    weak var listener: DetailPagePresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .random
    }

}

// MARK: - Helpers

extension UIColor {

    fileprivate static var random: UIColor {
        let range: Range<CGFloat> = 0..<1

        return UIColor(
            red: .random(in: range),
            green: .random(in: range),
            blue: .random(in: range),
            alpha: 1
        )
    }

}
