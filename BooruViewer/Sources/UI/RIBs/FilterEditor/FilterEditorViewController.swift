import UIKit
import SwiftUI
import ModernRIBs

protocol FilterEditorPresentableListener: AnyObject {
    func didDismiss()
}

final class FilterEditorViewController: UIViewController, FilterEditorPresentable, ViewControllable {

    // MARK: - Internal Properties

    weak var listener: FilterEditorPresentableListener?

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()

        embed(UIHostingController(rootView: FilterEditorView()))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isBeingDismissed else {
            return
        }

        listener?.didDismiss()
    }

}
