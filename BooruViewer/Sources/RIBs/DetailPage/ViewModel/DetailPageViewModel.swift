import UIKit
import SankakuAPI

enum DetailPageSection: Hashable {
    case images
}

enum DetailPageItem: Hashable {
    struct Image: Hashable {
        let previewURL: URL?
        let sampleURL: URL?
        let fileURL: URL?
    }

    case image(Image)
}

struct DetailPageViewModel: Hashable {

    // MARK: - Internal Types

    typealias Snapshot = NSDiffableDataSourceSnapshot<DetailPageSection, DetailPageItem>

    // MARK: - Internal Properties

    let post: Post

    var snapshot: Snapshot {
        var snapshot = Snapshot()

        // Images

        snapshot.appendSections([.images])
        snapshot.appendItems([.image(.init(
            previewURL: post.previewURL,
            sampleURL: post.sampleURL,
            fileURL: post.fileURL
        ))])

        return snapshot
    }

}
