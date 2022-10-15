import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUIFlow
import SankakuAPI

struct DetailPageView: View {

    let store: StoreOf<DetailPageFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            page(for: viewStore)
                .onAppear {
                    viewStore.send(.appear)
                }
                .navigationDestination(isPresented: isDetailFeedPresentedBinding(for: viewStore)) {
                    detailFeed
                }
        }
    }

    var detailFeed: some View {
        let store = self.store.scope { state in
            state.detailFeedState
        } action: { detailFeedAction in
            .detailFeedAction(detailFeedAction)
        }

        return IfLetStore(store) { store in
            DetailFeedView(store: store)
        }
    }

    @ViewBuilder
    func page(for viewStore: ViewStoreOf<DetailPageFeature>) -> some View {
        ScrollView {
            VStack {
                PostImageView(post: viewStore.post)
                    .listRowInsets(EdgeInsets())

                recommendenPosts(for: viewStore)

                if let tags = viewStore.post.tags {
                    VFlow(alignment: .leading) {
                        ForEach(tags) { tag in
                            TagView(tag: tag)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    @ViewBuilder
    func recommendenPosts(for viewStore: ViewStoreOf<DetailPageFeature>) -> some View {
        Group {
            Text("Recommended posts")
                .padding()

            switch viewStore.recommendedPosts {
            case let .success(posts):
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 2) {
                        ForEach(posts) { post in
                            WebImage(url: post.previewURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipped()
                                .onTapGesture {
                                    viewStore.send(.tapRecommendedPost(post))
                                }
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

    func isDetailFeedPresentedBinding(for viewStore: ViewStoreOf<DetailPageFeature>) -> Binding<Bool> {
        viewStore.binding(get: { $0.detailFeedState != nil }, send: .dismissDetailFeed)
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
