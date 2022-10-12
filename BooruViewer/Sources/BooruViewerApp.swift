import SwiftUI
import ComposableArchitecture

@main
struct BooruViewerApp: App {

    var body: some Scene {
        WindowGroup {
            MainFeedView(
                store: Store(
                    initialState: MainFeedFeature.State(),
                    reducer: MainFeedFeature()
                )
            )
        }
    }

}
