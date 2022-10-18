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
    private var onTapTag: ((Tag) -> Void)?

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

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: UIView.areAnimationsEnabled)

        guard let tag = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        onTapTag?(tag)
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

// MARK: - Factory Method

extension MainFeedSuggestedTagsController {

    static func make(onTapTag: @escaping (Tag) -> Void) -> MainFeedSuggestedTagsController {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout: UICollectionViewCompositionalLayout = .list(using: listConfiguration)

        let controller = MainFeedSuggestedTagsController(collectionViewLayout: layout)
        controller.onTapTag = onTapTag

        return controller
    }

}
