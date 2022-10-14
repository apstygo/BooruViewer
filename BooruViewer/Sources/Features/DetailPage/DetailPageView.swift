import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import SankakuAPI

struct DetailPageView: View {

    let store: StoreOf<DetailPageFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            page(for: viewStore)
                .onAppear {
                    viewStore.send(.appear)
                }
        }
    }

    @ViewBuilder
    func page(for viewStore: ViewStoreOf<DetailPageFeature>) -> some View {
        List {
            PostImageView(post: viewStore.post)
                .listRowInsets(EdgeInsets())

            recommendenPosts(for: viewStore)

            if let tags = viewStore.post.tags {
                ForEach(tags) { tag in
                    TagView(tag: tag)
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    func recommendenPosts(for viewStore: ViewStoreOf<DetailPageFeature>) -> some View {
        VStack(alignment: .leading) {
            Text("Recommended posts")

            switch viewStore.recommendedPosts {
            case let .success(posts):
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 2) {
                        ForEach(posts) { post in
                            WebImage(url: post.previewURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                        }
                    }
                }

            case .failure:
                Button("Retry loading") {
                    viewStore.send(.retryLoading)
                }

            case nil:
                ProgressView()
            }
        }
    }

}

private struct PostImageView: View {

    let post: Post

    var body: some View {
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
