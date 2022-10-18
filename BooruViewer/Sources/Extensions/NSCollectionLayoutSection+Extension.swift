import UIKit

extension NSCollectionLayoutSection {

    static func grid(preferredItemSize: CGFloat, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let availableWidth = layoutEnvironment.container.effectiveContentSize.width
        let size = (availableWidth / preferredItemSize).rounded(.toNearestOrAwayFromZero)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / size),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / size)
        )

        let group: NSCollectionLayoutGroup = .horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: Int(size)
        )

        return NSCollectionLayoutSection(group: group)
    }

    static func flow() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(50),
            heightDimension: .estimated(50)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: .fixed(4),
            trailing: .fixed(4),
            bottom: nil
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )

        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

}
