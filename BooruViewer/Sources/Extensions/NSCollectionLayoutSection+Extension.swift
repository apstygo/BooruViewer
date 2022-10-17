import UIKit

extension NSCollectionLayoutSection {

    static func grid(size: Int) -> NSCollectionLayoutSection {
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
