import SwiftUI
import ComposableArchitecture
import SankakuAPI

struct MainFeedView: View {

    typealias ViewStore = ViewStoreOf<MainFeedFeature>

    let store: StoreOf<MainFeedFeature>
    let spacing: CGFloat = 2

    @State var searchText: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(for: viewStore)
        }
    }

    @ViewBuilder
    func content(for viewStore: ViewStore) -> some View {
        mainContent(for: viewStore)
            .searchable(text: $searchText)
            .onAppear {
                viewStore.send(.appear)
            }
    }

    @ViewBuilder
    func mainContent(for viewStore: ViewStore) -> some View {
        if viewStore.feedState.shouldPresentFullscreenLoader {
            ProgressView()
        }
        else {
            GeometryReader { gr in
                ScrollView {
                    LazyVGrid(columns: calculateColumns(availableWidth: gr.size.width, preferredItemWidth: 200), spacing: spacing) {
                        ForEach(viewStore.feedState.posts) { post in
                            item(for: post, viewStore: viewStore)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func item(for post: Post, viewStore: ViewStore) -> some View {
        PostPreview(post: post)
            .contextMenu {
                Text("Menu item")
            } preview: {
                ContextMenuPostPreview(post: post)
            }
    }

    func calculateColumns(availableWidth: CGFloat, preferredItemWidth: CGFloat) -> [GridItem] {
        let itemCount = Int((availableWidth / preferredItemWidth).rounded(.toNearestOrAwayFromZero))
        let item = GridItem(.flexible(), spacing: spacing)
        return Array(repeating: item, count: itemCount)
    }

}

// MARK: - Previews

struct MainFeedView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            MainFeedView(
                store: Store(
                    initialState: MainFeedFeature.State(),
                    reducer: MainFeedFeature()
                )
            )
        }
    }

}

// MARK: - Helpers

extension Color {

    fileprivate static var random: Color {
        Color(
            red: .random(in: 0..<1),
            green: .random(in: 0..<1),
            blue: .random(in: 0..<1)
        )
    }

}

extension FeedState {

    fileprivate var shouldPresentFullscreenLoader: Bool {
        switch (posts.isEmpty, phase) {
        case (true, .idle), (true, .loading):
            return true

        default:
            return false
        }
    }

}
