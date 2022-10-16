import UIKit
import SwiftUI
import SDWebImageSwiftUI
import ModernRIBs
import SnapKit
import SankakuAPI

protocol MainFeedPresentableListener: AnyObject {
    func didShowCell(at indexPath: IndexPath)
    func didUpdateSearchText(_ searchText: String)
    func didCancelSearch()
}

final class MainFeedViewController: UIViewController, MainFeedViewControllable {

    // MARK: - Private Types

    private enum Section: Hashable {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Post>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Post>

    // MARK: - Internal Properties

    weak var listener: MainFeedPresentableListener?

    // MARK: - Private Properties

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private lazy var dataSource = configureDataSource()
    private var searchController: UISearchController!
    private lazy var suggestedTagsController: MainFeedSuggestedTagsController = .make()

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
    }

    // MARK: - Private Methods

    private func configureUI() {
        collectionView.dataSource = dataSource

        configureSearch()
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
        searchController.delegate = self
        searchController.searchBar.delegate = self

        definesPresentationContext = true
    }

    private func configureDataSource() -> DataSource {
        typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Post>
        let cellRegistration = CellRegistration { [listener] cell, indexPath, post in
            cell.contentConfiguration = UIHostingConfiguration {
                PostPreview(post: post)
                    .onAppear {
                        listener?.didShowCell(at: indexPath)
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

}

// MARK: - MainFeedPresentable

extension MainFeedViewController: MainFeedPresentable {

    func presentPosts(_ posts: [Post]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)

        dataSource.apply(snapshot)
    }

    func presentSuggestedTags(_ tags: [Tag]) {
        suggestedTagsController.presentTags(tags)
    }

}

// MARK: - UISearchControllerDelegate

extension MainFeedViewController: UISearchControllerDelegate {

}

// MARK: - UISearchBarDelegate

extension MainFeedViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listener?.didUpdateSearchText(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        listener?.didCancelSearch()
    }

}

// MARK: - UISearchResultsUpdating

extension MainFeedViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Implement
    }

}

// MARK: - PostPreview

private struct PostPreview: View {

    let post: Post

    var body: some View {
        GeometryReader { gr in
            WebImage(url: post.previewURL)
                .resizable()
                .scaledToFill()
                .frame(width: gr.size.width, height: gr.size.height)
                .clipped()
        }
    }

}

// MARK: - Helpers

extension NSCollectionLayoutSection {

    fileprivate static func grid(size: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / CGFloat(size)),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / CGFloat(size))
        )

        let group: NSCollectionLayoutGroup = .horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: size
        )

        return NSCollectionLayoutSection(group: group)
    }

}
