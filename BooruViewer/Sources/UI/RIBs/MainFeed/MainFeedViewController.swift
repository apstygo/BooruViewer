import UIKit
import SwiftUI
import SDWebImageSwiftUI
import ModernRIBs
import SnapKit
import SankakuAPI

protocol MainFeedPresentableListener: AnyObject {
    func didShowCell(at indexPath: IndexPath)
    func didUpdateSearch(withText searchText: String?, tags: [Tag])
    func didSelectTag(_ tag: Tag)
    func didSelectPost(_ post: Post)
    func didRefresh()
    func didPerformPreviewAction(for post: Post)
    func didDismissInteractively()
}

final class MainFeedViewController: UIViewController, MainFeedPresentable {

    // MARK: - Private Types

    private typealias DataSource = UICollectionViewDiffableDataSource<MainFeedSection, Post>

    // MARK: - Internal Properties

    weak var listener: MainFeedPresentableListener?

    var viewModel: MainFeedViewModel? {
        didSet {
            guard viewModel != oldValue else {
                return
            }

            applyViewModel()
        }
    }

    // MARK: - Private Properties

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private lazy var dataSource = configureDataSource()
    private var searchController: UISearchController!

    private lazy var suggestedTagsController: MainFeedSuggestedTagsController = .make { [weak listener] tag in
        listener?.didSelectTag(tag)
    }

    private var previewedPosts: [ObjectIdentifier: Post] = [:]

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        applyViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent {
            listener?.didDismissInteractively()
        }
    }

    // MARK: - Private Methods

    private func configureUI() {
        configureSearch()
        configureRefresh()

        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }

    private func configureSearch() {
        searchController = UISearchController(searchResultsController: suggestedTagsController)
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.searchTextField.placeholder = "Search using tags"

        navigationItem.searchController = searchController
        collectionView.keyboardDismissMode = .onDrag
        searchController.searchBar.delegate = self

        definesPresentationContext = true
    }

    private func configureRefresh() {
        let refreshAction = UIAction { [weak listener] _ in
            listener?.didRefresh()
        }

        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: refreshAction)
    }

    private func configureDataSource() -> DataSource {
        typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Post>
        let cellRegistration = CellRegistration { [weak listener] cell, indexPath, post in
            cell.contentConfiguration = UIHostingConfiguration {
                PostPreview(post: post)
                    .onAppear {
                        listener?.didShowCell(at: indexPath)
                    }
                    .onTapGesture {
                        listener?.didSelectPost(post)
                    }
            }
            .margins([.horizontal, .vertical], 0)
        }

        return DataSource(collectionView: collectionView) { collectionView, indexPath, post in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: post)
        }
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(section: .grid(size: 2))
    }

    private func applyViewModel() {
        guard isViewLoaded, let viewModel else {
            return
        }

        dataSource.apply(viewModel.snapshot)
        suggestedTagsController.presentTags(viewModel.suggestedTags)
        presentSearchTags(viewModel.searchTags)
        setSearchText(viewModel.searchText)

        if !viewModel.posts.isEmpty {
            collectionView.refreshControl?.endRefreshing()
        }
    }

    private func presentSearchTags(_ tags: [Tag]) {
        let searchField = searchController.searchBar.searchTextField

        searchField.tokens = tags.map { tag in
            let formattedName = tag.name.replacingOccurrences(of: "_", with: " ")
            let token = UISearchToken(icon: nil, text: formattedName)
            token.representedObject = tag
            return token
        }
    }

    private func setSearchText(_ text: String?) {
        let textField = searchController.searchBar.searchTextField

        if textField.text != text {
            textField.text = text
        }
    }

}

// MARK: - MainFeedViewControllable

extension MainFeedViewController: MainFeedViewControllable {

    func navigate(to viewController: ViewControllable) {
        guard let navigationController else {
            assertionFailure("Can't push without a stack")
            return
        }

        navigationController.pushViewController(viewController.uiviewController, animated: true)
    }

    func pop(_ viewController: ViewControllable) {
        guard let navigationController else {
            assertionFailure("Can't pop without a stack")
            return
        }

        guard !viewController.uiviewController.isMovingFromParent else {
            return
        }

        guard navigationController.viewControllers.last == viewController.uiviewController else {
            assertionFailure("The provided view controller is not at the top of the stack")
            return
        }

        navigationController.popViewController(animated: true)
    }

}

// MARK: - UISearchBarDelegate

extension MainFeedViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let tags = searchController.searchBar.searchTextField.tokens.map {
            $0.representedObject as! Tag
        }

        listener?.didUpdateSearch(withText: searchText, tags: tags)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        listener?.didUpdateSearch(withText: nil, tags: [])
    }

}

// MARK: - UISearchResultsUpdating

extension MainFeedViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Implement
    }

}

// MARK: - UICollectionViewDelegate

extension MainFeedViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard
            indexPaths.count == 1,
            let post = dataSource.itemIdentifier(for: indexPaths[0])
        else {
            return nil
        }

        let configuration = UIContextMenuConfiguration {
            let preview = ContextMenuPostPreview(post: post)
            let hostingController = UIHostingController(rootView: preview)
            hostingController.sizingOptions = .preferredContentSize
            return hostingController
        }

        previewedPosts[ObjectIdentifier(configuration)] = post

        return configuration
    }

    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        guard let post = previewedPosts[ObjectIdentifier(configuration)] else {
            return
        }

        animator.addCompletion { [weak listener] in
            listener?.didPerformPreviewAction(for: post)
        }
    }

}
