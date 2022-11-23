import SwiftUI
import ComposableArchitecture

struct MainFeedView: View {

    typealias ViewStore = ViewStoreOf<MainFeedFeature>

    let store: StoreOf<MainFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }

}

struct MainFeedView_Previews: PreviewProvider {

    static var previews: some View {
        MainFeedView(
            store: Store(
                initialState: MainFeedFeature.State(),
                reducer: MainFeedFeature()
            )
        )
    }

}
