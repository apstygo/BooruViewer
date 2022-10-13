import SwiftUI
import ComposableArchitecture
import Kingfisher

struct DetailFeedView: View {

    let store: StoreOf<DetailFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            KFImage(viewStore.post?.sampleURL)
                .resizable()
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
