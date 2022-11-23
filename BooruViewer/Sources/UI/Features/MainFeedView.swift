import SwiftUI
import ComposableArchitecture
import SankakuAPI

struct MainFeedView: View {

    let store: StoreOf<MainFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MainFeedContent(viewStore: viewStore)
        }
    }

}

private struct MainFeedContent: View {

    @ObservedObject var viewStore: ViewStoreOf<MainFeedFeature>
    @State var searchText: String = ""
    let spacing: CGFloat = 2

    var body: some View {
        content
            .searchable(text: $searchText)
            .onAppear {
                viewStore.send(.appear)
            }
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        LazyVGrid(columns: calculateColumns(availableWidth: gr.size.width, preferredItemWidth: 200), spacing: spacing) {
                            ForEach(viewStore.posts) { post in
                                item(for: post)
                            }
                        }

                        if !viewStore.shouldPresentFullscreenLoader {
                            ProgressView()
                        }
                    }
                }
            }
            .refreshable {
                viewStore.send(.refresh)
            }

            if viewStore.shouldPresentFullscreenLoader {
                ProgressView()
            }
        }
        .animation(.default, value: viewStore.posts)
    }

    @ViewBuilder
    func item(for post: Post) -> some View {
        PostPreview(post: post)
            .contextMenu {
                Text("Menu item")
            } preview: {
                ContextMenuPostPreview(post: post)
            }
            .onAppear {
                viewStore.send(.postAppeared(post))
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

extension MainFeedFeature.State {

    fileprivate var shouldPresentFullscreenLoader: Bool {
        switch (posts.isEmpty, feedPhase) {
        case (true, .idle), (true, .loading):
            return true

        default:
            return false
        }
    }

}
