import Foundation

// TODO: Add missing fields
public struct Tag: Decodable, Hashable, Identifiable, Equatable {
    public enum TagType: Int, Decodable, Equatable {
        case general = 0
        case artist = 1
        case studio = 2
        case copyright = 3
        case character = 4
        case genre = 5
        case medium = 8
        case meta = 9
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case postCount = "post_count"
        case poolCount = "pool_count"
        case seriesCount = "series_count"
        case tagType = "type"
    }

    public let id: Int
    public let name: String
    public let postCount: Int
    public let poolCount: Int
    public let seriesCount: Int
    public let tagType: TagType
}
