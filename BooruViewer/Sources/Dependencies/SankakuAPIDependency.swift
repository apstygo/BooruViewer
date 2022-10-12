import ComposableArchitecture
import SankakuAPI

private enum SankakuAPIKey: DependencyKey {
    static let liveValue = SankakuAPI()
}

extension DependencyValues {
    var sankakuAPI: SankakuAPI {
        get { self[SankakuAPIKey.self] }
        set { self[SankakuAPIKey.self] = newValue }
    }
}
