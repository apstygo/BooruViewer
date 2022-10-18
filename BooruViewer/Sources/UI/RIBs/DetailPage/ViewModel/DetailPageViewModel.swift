import UIKit
import SankakuAPI

enum DetailPageSection: Hashable {
    case images
    case tags
    case relatedPosts
}

enum DetailPageItem: Hashable {
    struct Image: Hashable {
        let previewURL: URL?
        let sampleURL: URL?
        let sampleWidth: CGFloat?
        let sampleHeight: CGFloat?
        let fileURL: URL?
    }

    case image(Image)
    case tag(Tag)
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
            sampleWidth: post.sampleWidth,
            sampleHeight: post.sampleHeight,
            fileURL: post.fileURL
        ))])

        // Tags

        snapshot.appendSections([.tags])
        snapshot.appendItems(post.tags.map { .tag($0) })

        // Related Posts

        snapshot.appendSections([.relatedPosts])
        snapshot.appendItems(relatedPosts.map { .relatedPost($0) })

        return snapshot
    }

}
