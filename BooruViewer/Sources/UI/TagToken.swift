
enum TagToken: Hashable, Identifiable {

    case tag(Tag)
    case raw(String)

    var id: String {
        tagName
    }

    var tagName: String {
        switch self {
        case let .tag(tag):
            return tag.name

        case let .raw(tagName):
            return tagName
        }
    }

}
