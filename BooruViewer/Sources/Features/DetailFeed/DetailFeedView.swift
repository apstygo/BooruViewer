import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import SankakuAPI

struct DetailFeedView: View {

    let store: StoreOf<DetailFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(for: viewStore)
                .onAppear {
                    viewStore.send(.appear)
                }
        }
    }

    @ViewBuilder
    func content(for viewStore: ViewStoreOf<DetailFeedFeature>) -> some View {
        if viewStore.posts.isEmpty {
            Text("Empty")
        }
        else {
            tabView(for: viewStore)
        }
    }

    @ViewBuilder
    func tabView(for viewStore: ViewStoreOf<DetailFeedFeature>) -> some View {
        TabView(selection: selectedPageBinding(for: viewStore)) {
            ForEach(viewStore.posts, id: \.index) { post in
                page(for: post.post)
                    .tag(post.index)    // tag for page binding
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    @ViewBuilder
    func page(for post: Post) -> some View {
        List {
            image(for: post)
                .listRowInsets(EdgeInsets())

            if let tags = post.tags {
                ForEach(tags) { tag in
                    TagView(tag: tag)
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    func image(for post: Post) -> some View {
        WebImage(url: post.sampleURL)
            .placeholder {
                WebImage(url: post.previewURL)
                    .resizable()
                    .scaledToFit()
            }
            .resizable()
            .scaledToFit()
    }

    func selectedPageBinding(for viewStore: ViewStoreOf<DetailFeedFeature>) -> Binding<Int> {
        viewStore.binding { state in
            state.postIndex
        } send: { postIndex in
            .scrollToPost(postIndex)
        }
    }

}

struct DetailFeedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailFeedView(
            store: Store(
                initialState: DetailFeedFeature.State(postIndex: 0),
                reducer: DetailFeedFeature()
            )
        )
    }
}
