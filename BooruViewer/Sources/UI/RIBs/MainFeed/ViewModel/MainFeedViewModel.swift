import UIKit
import SankakuAPI

enum MainFeedSection: Hashable {
    case main
}

struct MainFeedViewModel: Hashable {

    // MARK: - Internal Types

    typealias Snapshot = NSDiffableDataSourceSnapshot<MainFeedSection, Post>

    // MARK: - Internal Properties

    var posts: [Post] = []
    var searchTags: [Tag] = []
    var suggestedTags: [Tag] = []
    var isRefreshing = false
    var searchText: String?

    var snapshot: Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        return snapshot
    }

}
