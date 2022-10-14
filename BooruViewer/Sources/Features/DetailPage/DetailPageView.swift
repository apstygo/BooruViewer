import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import SankakuAPI

struct DetailPageView: View {

    let store: StoreOf<DetailPageFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            page(for: viewStore)
        }
    }

    @ViewBuilder
    func page(for viewStore: ViewStoreOf<DetailPageFeature>) -> some View {
        List {
            image(for: viewStore.post)
                .listRowInsets(EdgeInsets())

            if let tags = viewStore.post.tags {
                ForEach(tags) { tag in
                    TagView(tag: tag)
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    func image(for post: Post) -> some View {
        WebImage(url: post.sampleURL, options: .highPriority)
            .placeholder {
                WebImage(url: post.previewURL, options: .highPriority)
                    .resizable()
                    .scaledToFit()
            }
            .resizable()
            .scaledToFit()
    }

}

//struct DetailPageView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        DetailPageView(
//            store: Store(
//                initialState: ,
//                reducer:
//            )
//        )
//    }
//
//}
