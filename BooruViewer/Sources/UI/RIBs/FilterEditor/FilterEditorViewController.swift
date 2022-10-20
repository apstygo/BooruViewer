import UIKit
import SwiftUI
import ModernRIBs

protocol FilterEditorPresentableListener: AnyObject {
    func didDismiss()
    func didApply()
}

final class FilterEditorViewController: UIViewController, FilterEditorPresentable, ViewControllable {

    // MARK: - Internal Properties

    weak var listener: FilterEditorPresentableListener?

    // MARK: - Private Properties

    private lazy var viewModel = FilterEditorViewModel { [weak listener] in
        listener?.didApply()
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()

        embed(UIHostingController(rootView: FilterEditorView(viewModel: viewModel)))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isBeingDismissed else {
            return
        }

        listener?.didDismiss()
    }

}
