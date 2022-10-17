import UIKit
import SankakuAPI

enum DetailPageSection: Hashable {
    case images
    case relatedPosts
}

enum DetailPageItem: Hashable {
    struct Image: Hashable {
        let previewURL: URL?
        let sampleURL: URL?
        let fileURL: URL?
    }

    case image(Image)
    case relatedPost(Post)
}

struct DetailPageViewModel: Hashable {

    // MARK: - Internal Types

    typealias Snapshot = NSDiffableDataSourceSnapshot<DetailPageSection, DetailPageItem>

    // MARK: - Internal Properties

    let post: Post
    let relatedPosts: [Post]

    var snapshot: Snapshot {
        var snapshot = Snapshot()

        // Images

        snapshot.appendSections([.images])
        snapshot.appendItems([.image(.init(
            previewURL: post.previewURL,
            sampleURL: post.sampleURL,
            fileURL: post.fileURL
        ))])

        // Related Posts

        snapshot.appendSections([.relatedPosts])
        snapshot.appendItems(relatedPosts.map { .relatedPost($0) })

        return snapshot
    }

}
