import Foundation

public struct GetPostsFilters: Hashable {
    public var gRatingIncluded: Bool
    public var r15RatingIncluded: Bool
    public var r18RatingIncluded: Bool
    public var sortOrder: SortOrder
    public var threshold: Threshold
    public var hidePostsInBooks: HidePostsInBooks
    public var mediaSize: MediaSize
    public var mediaType: MediaType

    public init(gRatingIncluded: Bool = true,
                r15RatingIncluded: Bool = false,
                r18RatingIncluded: Bool = false,
                sortOrder: SortOrder = .date,
                threshold: Threshold = .zero,
                hidePostsInBooks: HidePostsInBooks = .never,
                mediaSize: MediaSize = .any,
                mediaType: MediaType = .any) {
        self.gRatingIncluded = gRatingIncluded
        self.r15RatingIncluded = r15RatingIncluded
        self.r18RatingIncluded = r18RatingIncluded
        self.sortOrder = sortOrder
        self.threshold = threshold
        self.hidePostsInBooks = hidePostsInBooks
        self.mediaSize = mediaSize
        self.mediaType = mediaType
    }
}

extension GetPostsFilters {

    public var tags: [String] {
        var tags = [
            "order:\(sortOrder.rawValue)"
        ]

        for rating in ratings {
            tags.append("rating:\(rating.rawValue)")
        }

        if mediaType != .any {
            tags.append("file_type:\(mediaType.rawValue)")
        }

        if mediaSize != .any {
            tags.append("+\(mediaSize.rawValue)")
        }

        if threshold != .zero {
            tags.append("threshold:\(threshold.rawValue)")
        }

        if hidePostsInBooks != .never {
            tags.append("hide_posts_in_books:\(hidePostsInBooks.rawValue)")
        }

        return tags
    }

    public var ratings: Set<Rating> {
        var ratings: Set<Rating> = []

        if gRatingIncluded {
            ratings.insert(.g)
        }

        if r15RatingIncluded {
            ratings.insert(.r15)
        }

        if r18RatingIncluded {
            ratings.insert(.r18)
        }

        return ratings
    }

}
