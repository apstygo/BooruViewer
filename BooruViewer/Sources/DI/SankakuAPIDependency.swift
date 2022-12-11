import ComposableArchitecture
import SankakuAPI

private enum SankakuAPIKey: DependencyKey {
    static let liveValue = SankakuAPI(sessionConfiguration: .patient)
}

extension DependencyValues {

    var sankakuAPI: SankakuAPI {
        get { self[SankakuAPIKey.self] }
        set { self[SankakuAPIKey.self] = newValue }
    }

}
