import CombineExt
import SankakuAPI

enum FeedPhase: Hashable {
    case idle
    case loading
    case error
    case finished
}

struct FeedState: Hashable {
    var posts: [Post] = []
    var phase: FeedPhase = .idle
}

protocol Feed {

    var state: FeedState { get }
    var stateStream: AsyncStream<FeedState> { get }

    func reload()
    func loadPage(forItemAt index: Int)

}

final class FeedImpl: Feed {

    // MARK: - Private Types

    private enum Constant {
        static let pageSize = 50
        static let loadThreshold = 25
    }

    // MARK: - Internal Properties

    var state: FeedState {
        get { stateRelay.value }
        set { stateRelay.accept(newValue) }
    }

    var stateStream: AsyncStream<FeedState> {
        AsyncStream(stateRelay.removeDuplicates().values)
    }

    // MARK: - Private Properties

    private let sankakuAPI: SankakuAPI

    private let stateRelay = CurrentValueRelay(FeedState())
    private var reloadTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var nextPageId: String?

    // MARK: - Init

    init(sankakuAPI: SankakuAPI) {
        self.sankakuAPI = sankakuAPI
    }

    // MARK: - Internal Methods

    func reload() {
        guard reloadTask == nil else {
            return
        }

        loadTask?.cancel()
        loadTask = nil

        nextPageId = nil
        state = FeedState(posts: [], phase: .loading)

        reloadTask = Task {
            await loadMore()
            reloadTask = nil
        }
    }

    func loadPage(forItemAt index: Int) {
        guard reloadTask == nil, loadTask == nil, shouldLoadPage(forItemAt: index) else {
            return
        }

        state.phase = .loading

        loadTask = Task {
            await loadMore()
            loadTask = nil
        }
    }

    // MARK: - Private Methods

    private func loadMore() async {
        do {
            let postsResponse = try await sankakuAPI.getPosts(
                limit: Constant.pageSize,
                next: nextPageId
            )

            nextPageId = postsResponse.meta.next
            state.posts.append(contentsOf: postsResponse.data)

            state.phase = (postsResponse.data.count == Constant.pageSize) ? .idle : .finished
        }
        catch {
            state.phase = .error
        }
    }

    private func shouldLoadPage(forItemAt index: Int) -> Bool {
        let (pageCount, remainder) = state.posts.count.quotientAndRemainder(dividingBy: Constant.pageSize)

        guard remainder == 0 else {
            return false
        }

        guard pageCount != 0 else {
            return true
        }

        let upperBound = pageCount * Constant.pageSize
        let lowerBound = upperBound - Constant.loadThreshold

        return (lowerBound...upperBound).contains(index)
    }

}
