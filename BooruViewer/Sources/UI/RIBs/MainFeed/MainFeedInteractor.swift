import UIKit
import Combine
import CombineExt
import ModernRIBs
import SankakuAPI

enum MainFeedMode {
    case primary
    case tag(Tag)
}

protocol MainFeedRouting: ViewableRouting {
    func attachDetailFeed(for post: Post)
    func detachDetailFeed()
}

protocol MainFeedPresentable: Presentable {
    var listener: MainFeedPresentableListener? { get set }
    var viewModel: MainFeedViewModel? { get set }
}

protocol MainFeedListener: AnyObject {
    func mainFeedDidDismiss()
}

final class MainFeedInteractor: PresentableInteractor<MainFeedPresentable>, MainFeedInteractable, MainFeedPresentableListener {

    // MARK: - Internal Properties

    weak var router: MainFeedRouting?
    weak var listener: MainFeedListener?

    // MARK: - Private Properties

    private let sankakuAPI: SankakuAPI
    private let feed: Feed
    private let mode: MainFeedMode

    private let searchTagRelay: CurrentValueRelay<[Tag]>
    private let searchTextRelay = CurrentValueRelay<String?>(nil)

    private var disposeBag: [AnyCancellable] = []

    private var searchTags: [Tag] {
        get { searchTagRelay.value }
        set { searchTagRelay.accept(newValue) }
    }

    // MARK: - Init

    init(sankakuAPI: SankakuAPI,
         feed: Feed,
         mode: MainFeedMode,
         presenter: MainFeedPresentable) {
        self.sankakuAPI = sankakuAPI
        self.feed = feed
        self.mode = mode

        switch mode {
        case .primary:
            self.searchTagRelay = CurrentValueRelay([])

        case let .tag(tag):
            self.searchTagRelay = CurrentValueRelay([tag])
        }

        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Lifecycle

    override func didBecomeActive() {
        super.didBecomeActive()

        startPostObserving()
    }

    override func willResignActive() {
        super.willResignActive()

        disposeBag.removeAll()
    }

    // MARK: - Presentable Listener

    func didShowCell(at indexPath: IndexPath) {
        feed.loadPage(forItemAt: indexPath.item)
    }

    func didUpdateSearch(withText searchText: String?, tags: [Tag]) {
        // Suggest new tags for search text

        searchTextRelay.accept(searchText)

        // Set current tags

        searchTags = tags
    }

    func didSelectTag(_ tag: Tag) {
        searchTags.append(tag)
        searchTextRelay.accept(nil)
    }

    func didSelectPost(_ post: Post) {
        router?.attachDetailFeed(for: post)
    }

    func didRefresh() {
        feed.reload()
    }

    func didPerformPreviewAction(for post: Post) {
        router?.attachDetailFeed(for: post)
    }

    func didDismissInteractively() {
        listener?.mainFeedDidDismiss()
    }

    // MARK: - Private Methods

    private func startPostObserving() {
        let postPublisher = feed.statePublisher
            .map(\.posts)

        let suggestedTagPublisher = Publishers.CombineLatest(searchTextRelay, searchTagRelay)
            .flatMapLatest { [sankakuAPI] searchText, searchTags -> AnyPublisher<[Tag], Never> in
                guard let searchText, !searchText.isEmpty else {
                    return Just([]).eraseToAnyPublisher()
                }

                return sankakuAPI.autoSuggestTags(for: searchText)
                    .map { tags in
                        tags.filter { tag in
                            !searchTags.contains { $0.name == tag.name }
                        }
                    }
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }

        Publishers.CombineLatest4(postPublisher, searchTagRelay, searchTextRelay, suggestedTagPublisher)
            .map { posts, searchTags, searchText, suggestedTags in
                MainFeedViewModel(
                    posts: posts,
                    searchTags: searchTags,
                    suggestedTags: suggestedTags,
                    isRefreshing: false,
                    searchText: searchText
                )
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak presenter] viewModel in
                presenter?.viewModel = viewModel
            }
            .store(in: &disposeBag)

        searchTagRelay
            .removeDuplicates()
            .sink { [feed] tags in
                feed.tags = tags
                feed.reload()
            }
            .store(in: &disposeBag)

        feed.reload()
    }

}

// MARK: - DetailFeedListener

extension MainFeedInteractor: DetailFeedListener {

    func detailFeedDidDismiss() {
        router?.detachDetailFeed()
    }

}

// MARK: - Helpers

extension SankakuAPI {

    fileprivate func autoSuggestTags(for query: String) -> AnyPublisher<[Tag], Error> {
        AnyPublisher { [self] in
            try await autoSuggestTags(for: query)
        }
    }

}
