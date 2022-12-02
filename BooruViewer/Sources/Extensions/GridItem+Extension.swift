import SwiftUI

extension Array where Element == GridItem {

    static func `dynamic`(availableWidth: CGFloat,
                          preferredItemWidth: CGFloat = 200,
                          spacing: CGFloat) -> Self {
        var itemCount = Int((availableWidth / preferredItemWidth).rounded(.toNearestOrAwayFromZero))
        itemCount = Swift.max(itemCount, 1)
        let item = GridItem(.flexible(), spacing: spacing)
        return Array(repeating: item, count: itemCount)
    }

}
