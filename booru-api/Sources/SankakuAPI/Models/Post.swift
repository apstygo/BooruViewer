import Foundation

public struct Post: Decodable, Hashable, Equatable, Identifiable {
    public enum CodingKeys: String, CodingKey {
        case id
        case previewURL = "preview_url"
        case previewWidth = "preview_width"
        case previewHeight = "preview_height"
        case sampleURL = "sample_url"
        case sampleWidth = "sample_width"
        case sampleHeight = "sample_height"
        case fileURL = "file_url"
        case width
        case height
        case tags
    }

    public let id: Int
    public let previewURL: URL?
    public let previewWidth: CGFloat?
    public let previewHeight: CGFloat?
    public let sampleURL: URL?
    public let sampleWidth: CGFloat?
    public let sampleHeight: CGFloat?
    public let fileURL: URL?
    public let width: CGFloat?
    public let height: CGFloat?
    public let tags: [Tag]
}

extension Post {

    var previewSize: CGSize? {
        guard let previewWidth, let previewHeight else {
            return nil
        }

        return CGSize(width: previewWidth, height: previewHeight)
    }

    var sampleSize: CGSize? {
        guard let sampleWidth, let sampleHeight else {
            return nil
        }

        return CGSize(width: sampleWidth, height: sampleHeight)
    }

}
