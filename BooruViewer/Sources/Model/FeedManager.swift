import Combine
import CombineExt
import SankakuAPI

enum FeedManagerState {
    case idle
    case loading
    case error
    case finished
}

protocol FeedManager {

    var posts: [Post] { get async }
    var state: FeedManagerState { get async }

    func reload() async
    func loadNextPage() async
    func setTags(_ tags: [Tag]) async

}

actor FeedManagerImpl: FeedManager {

    // MARK: - Private Types

    private enum Constant {
        static let pageSize = 50
    }

    // MARK: - Internal Properties

    private(set) var posts: [Post] = []
    private(set) var state: FeedManagerState = .idle

    // MARK: - Private Properties

    private let sankakuAPI: SankakuAPI

    private var tags: [Tag] = []
    private var nextPageId: String?

    // MARK: - Init

    init(sankakuAPI: SankakuAPI) {
        self.sankakuAPI = sankakuAPI
    }

    // MARK: - Internal Methods

    func reload() async {
        posts = []
        state = .idle
        nextPageId = nil

        await load()
    }

    func loadNextPage() async {
        await load()
    }

    func setTags(_ tags: [Tag]) async {
        self.tags = tags
    }

    // MARK: - Private Methods

    private func load() async {
        guard state != .finished else {
            return
        }

        do {
            state = .loading

            let response = try await sankakuAPI.getPosts(
                tags: tags.map(\.name),
                limit: Constant.pageSize,
                next: nextPageId
            )

            nextPageId = response.meta.next
            posts.append(contentsOf: response.data)

            state = (response.data.count >= Constant.pageSize) ? .idle : .finished
        }
        catch {
            state = .error
        }
    }

}
