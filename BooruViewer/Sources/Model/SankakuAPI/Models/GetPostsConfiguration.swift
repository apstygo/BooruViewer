import Foundation

public struct GetPostsConfiguration {
    public var filters: GetPostsFilters
    public var tags: [String]
    public var limit: Int
    public var next: String?
    public var prev: String?

    public init(
        filters: GetPostsFilters = .init(),
        tags: [String] = [],
        limit: Int = 40,
        next: String? = nil,
        prev: String? = nil
    ) {
        self.filters = filters
        self.tags = tags
        self.limit = limit
        self.next = next
        self.prev = prev
    }
}

extension GetPostsConfiguration {

    var params: [String: Any] {
        var params: [String: Any] = [:]

        // Tags

        let allTags = tags + filters.tags

        // Params

        params = [
            "lang": "en",
            "limit": limit,
            "tags": allTags.joined(separator: " ")
        ]

        if let next {
            params["next"] = next
        }

        if let prev {
            params["prev"] = prev
        }

        return params
    }

}
