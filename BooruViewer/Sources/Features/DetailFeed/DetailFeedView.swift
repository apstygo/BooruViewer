import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import SankakuAPI

struct DetailFeedView: View {

    let store: StoreOf<DetailFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(for: viewStore)
        }
    }

    @ViewBuilder
    func content(for viewStore: ViewStoreOf<DetailFeedFeature>) -> some View {
        List {
            image(for: viewStore)
                .listRowInsets(EdgeInsets())

            if let tags = viewStore.post?.tags {
                ForEach(tags) { tag in
                    TagView(tag: tag)
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    func image(for viewStore: ViewStoreOf<DetailFeedFeature>) -> some View {
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
