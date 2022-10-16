import UIKit
import SnapKit

extension UIViewController {

    func embed(_ viewController: UIViewController) {
        guard viewController.parent == nil else {
            assertionFailure("Trying to embed a view controller that already has a parent")
            return
        }

        addChild(viewController)

        view.addSubview(viewController.view)

        viewController.view.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        viewController.didMove(toParent: self)
    }

}
