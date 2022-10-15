import SwiftUI
import ComposableArchitecture

//@main
struct BooruViewerApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainFeedView(
                    store: Store(
                        initialState: MainFeedFeature.State(),
                        reducer: MainFeedFeature()
                    )
                )
            }
        }
    }

}
