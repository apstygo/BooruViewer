import Foundation
import SankakuAPI

final class FilterEditorViewModel: ObservableObject {

    // MARK: - Internal Properties

    @Published var filters = GetPostsFilters()

    // MARK: - Private Properties

    private let onApplyHandler: () -> Void

    // MARK: - Init

    init(onApplyHandler: @escaping () -> Void) {
        self.onApplyHandler = onApplyHandler
    }

    // MARK: - Internal Methods

    func onApply() {
        onApplyHandler()
    }

}
