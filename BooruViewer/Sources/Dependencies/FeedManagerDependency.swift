import ComposableArchitecture
import SankakuAPI

private enum FeedManagerKey: DependencyKey {
    static let liveValue: any FeedManager = FeedManagerImpl(sankakuAPI: SankakuAPI())
}

extension DependencyValues {
    var feedManager: FeedManager {
        get { self[FeedManagerKey.self] }
        set { self[FeedManagerKey.self] = newValue }
    }
}
