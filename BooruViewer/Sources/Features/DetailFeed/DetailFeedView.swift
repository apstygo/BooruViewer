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
            ForEach(viewStore.pageStates) { pageState in
                page(for: pageState.id)
                    .tag(pageState.id)    // tag for page binding
            }

            Text("Loading next post...")
                .tag(-1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    func page(for id: DetailPageFeature.State.ID) -> some View {
        let store = self.store.scope { state in
            state.pageStates[id: id]
        } action: { childAction in
            .detailPageAction(id, childAction)
        }

        return IfLetStore(store) { store in
            DetailPageView(store: store)
        }
    }

    func selectedPageBinding(for viewStore: ViewStoreOf<DetailFeedFeature>) -> Binding<DetailPageFeature.State.ID> {
        viewStore.binding { state in
            state.currentPage
        } send: { pageId in
            .scrollToPage(pageId)
        }
    }

}
