import UIKit
import ModernRIBs

protocol DetailFeedPresentableListener: AnyObject {
    func didPop()
}

final class DetailFeedViewController: UIViewController, DetailFeedPresentable, DetailFeedViewControllable {

    // MARK: - Internal Properties

    weak var listener: DetailFeedPresentableListener?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isMovingFromParent else {
            return
        }

        listener?.didPop()
    }

}
