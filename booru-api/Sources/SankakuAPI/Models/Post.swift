import Foundation

public struct Post: Decodable, Hashable, Identifiable {
    public enum FileType: Decodable, Hashable {
        public enum ImageFormat: String {
            case jpeg
            case png
            case gif
        }

        public enum VideoFormat: String {
            case mp4
            case webm
        }

        case image(ImageFormat)
        case video(VideoFormat)
    }

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
        case source
        case fileType = "file_type"
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
    public let source: String?
    public let fileType: FileType
}

extension Post {

    public var sourceURL: URL? {
        guard let source else {
            return nil
        }

        return URL(string: source)
    }

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

extension Post.FileType: RawRepresentable {

    public var rawValue: String {
        switch self {
        case let .image(format):
            return "image/\(format.rawValue)"

        case let .video(format):
            return "video/\(format.rawValue)"
        }
    }

    public init?(rawValue: String) {
        let components = rawValue.components(separatedBy: "/")

        guard components.count == 2 else {
            return nil
        }

        switch components[0] {
        case "image":
            guard let format = ImageFormat(rawValue: components[1]) else {
                return nil
            }

            self = .image(format)

        case "video":
            guard let format = VideoFormat(rawValue: components[1]) else {
                return nil
            }

            self = .video(format)

        default:
            return nil
        }
    }

}
