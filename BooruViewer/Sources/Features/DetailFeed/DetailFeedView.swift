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
        TabView(selection: selectedPageBinding(for: viewStore)) {
            ForEach(viewStore.posts, id: \.index) { post in
                page(for: post.post)
                    .tag(post.index)    // tag for page binding
            }

            Text("Loading next post...")
                .tag(viewStore.posts.count)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    func page(for post: Post) -> some View {
        let store = self.store.scope { state in
            state.pageStates[post]!
        } action: { childAction in
            .detailPageAction(post, childAction)
        }

        return DetailPageView(store: store)
    }

    func selectedPageBinding(for viewStore: ViewStoreOf<DetailFeedFeature>) -> Binding<Int> {
        viewStore.binding { state in
            state.postIndex
        } send: { postIndex in
            .scrollToPost(postIndex)
        }
    }

}

//struct DetailFeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailFeedView(
//            store: Store(
//                initialState: DetailFeedFeature.State(postIndex: 0),
//                reducer: DetailFeedFeature()
//            )
//        )
//    }
//}
