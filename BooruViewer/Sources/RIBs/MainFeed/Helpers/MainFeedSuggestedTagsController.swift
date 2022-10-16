import UIKit
import SwiftUI
import SankakuAPI

final class MainFeedSuggestedTagsController: UICollectionViewController {

    // MARK: - Private Types

    private enum Section: Hashable {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Tag>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Tag>

    // MARK: - Private Properties

    private lazy var dataSource: DataSource = makeDataSource()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Internal Methods

    func presentTags(_ tags: [Tag]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(tags)

        dataSource.apply(snapshot)
    }

    // MARK: - Private Methods

    private func configureUI() {
        collectionView.dataSource = dataSource
    }

    private func makeDataSource() -> DataSource {
        typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Tag>
        let cellRegistration = CellRegistration { cell, _, tag in
            cell.contentConfiguration = UIHostingConfiguration {
                TagView(tag: tag)
            }
        }

        return DataSource(collectionView: collectionView) { collectionView, indexPath, tag in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: tag)
        }
    }

}

extension MainFeedSuggestedTagsController {

    static func make() -> MainFeedSuggestedTagsController {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout: UICollectionViewCompositionalLayout = .list(using: listConfiguration)
        return .init(collectionViewLayout: layout)
    }

}
