import UIKit
import SwiftUI
import Combine
import ModernRIBs
import SankakuAPI

protocol FilterEditorPresentableListener: AnyObject {
    func didUpdateFilters(_ newFilters: GetPostsFilters)
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

    private var disposeBag: [AnyCancellable] = []

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()

        embed(UIHostingController(rootView: FilterEditorView(viewModel: viewModel)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$filters
            .sink { [weak listener] filters in
                listener?.didUpdateFilters(filters)
            }
            .store(in: &disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isBeingDismissed else {
            return
        }

        listener?.didDismiss()
    }

    // MARK: - Presentable

    func presentFilters(_ filters: GetPostsFilters) {
        viewModel.filters = filters
    }

}
