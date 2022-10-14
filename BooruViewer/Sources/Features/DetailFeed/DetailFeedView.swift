import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

struct DetailFeedView: View {

    let store: StoreOf<DetailFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            WebImage(url: viewStore.post?.sampleURL)
                .placeholder {
                    WebImage(url: viewStore.post?.previewURL)
                        .resizable()
                        .scaledToFit()
                }
                .resizable()
                .scaledToFit()
        }
    }

}

struct DetailFeedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailFeedView(
            store: Store(
                initialState: DetailFeedFeature.State(),
                reducer: DetailFeedFeature()
            )
        )
    }
}
