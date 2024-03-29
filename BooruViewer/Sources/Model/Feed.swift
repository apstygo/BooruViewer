import Combine
import CombineExt

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

protocol Feed: AnyObject {
    var state: FeedState { get }
    var statePublisher: AnyPublisher<FeedState, Never> { get }
    var tags: [Tag] { get set }
    var customTags: [String] { get set }
    var filters: GetPostsFilters { get set }

    func reload()
    func loadPage(forItemAt index: Int)
}

extension Feed {
    var stateStream: AsyncStream<FeedState> {
        AsyncStream { continuation in
            let cancellable = statePublisher.sink { _ in
                continuation.finish()
            } receiveValue: { state in
                continuation.yield(state)
            }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
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

    var statePublisher: AnyPublisher<FeedState, Never> {
        stateRelay.eraseToAnyPublisher()
    }

    var tags: [Tag] = []
    var customTags: [String] = []
    var filters = GetPostsFilters()

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
                filters: filters,
                tags: tags.map(\.name) + customTags,
                limit: Constant.pageSize,
                next: nextPageId
            )

            nextPageId = postsResponse.meta.next
            state.posts.append(contentsOf: postsResponse.data)

            state.phase = (postsResponse.data.count == Constant.pageSize) ? .idle : .finished
        }
        catch {
            print("⚠️ \(error)")
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
