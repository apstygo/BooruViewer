import SwiftUI
import ComposableArchitecture
import SwiftUINavigation
import SankakuAPI

struct MainFeedView: View {

    let store: StoreOf<MainFeedFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MainFeedContent(store: store, viewStore: viewStore)
        }
    }

}

private struct MainFeedContent: View {

    let store: StoreOf<MainFeedFeature>
    @ObservedObject var viewStore: ViewStoreOf<MainFeedFeature>
    let spacing: CGFloat = 2

    var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS)
            .navigationBarDrawer(displayMode: .always)
        #else
            .automatic
        #endif
    }

    // MARK: - Layout

    var body: some View {
        content
            .onAppear {
                viewStore.send(.appear)
            }
            .searchable(
                text: searchTextBinding,
                tokens: tokenBinding,
                suggestedTokens: suggestedTokenBinding,
                placement: searchFieldPlacement,
                prompt: "Search using tags"
            ) { token in
                TagView(tagToken: token)
            }
            .scrollDismissesKeyboard(.immediately)
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
            .toolbar {
                #if os(macOS)
                ToolbarItem {
                    Button {
                        viewStore.send(.refresh)
                    } label: {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewStore.isDoingInitialLoading)
                    .keyboardShortcut("R", modifiers: .command)
                }
                #endif

                ToolbarItem {
                    Button {
                        viewStore.send(.presentFilters)
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
            .sheet(isPresented: isFilterEditorPresented) {
                IfLetStore(store.scope(state: { $0.filterEditorState }, action: { .filterEditor($0) })) { store in
                    FilterEditorView(store: store)
                }
            }
            .navigationDestination(isPresented: isPostDetailPresented) {
                IfLetStore(store.scope(state: { $0.postDetailState }, action: { .postDetail($0) })) { store in
                    PostDetailView(store: store)
                }
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

                        if !viewStore.isDoingInitialLoading {
                            ProgressView()
                        }
                    }
                }
            }
            .refreshable {
                viewStore.send(.refresh)
            }

            if viewStore.isDoingInitialLoading {
                ProgressView()
            }
        }
        .animation(.default, value: viewStore.posts)
    }

    @ViewBuilder
    func item(for post: Post) -> some View {
        PostPreview(post: post)
            .contextMenu {
                Button {
                    viewStore.send(.openPost(post))
                } label: {
                    Label("Open post", systemImage: "photo")
                }

                Button {
                    // Do nothing
                } label: {
                    Label("Favorite", systemImage: "heart")
                }
                .disabled(true)

                if let sourceURL = post.sourceURL {
                    Link(destination: sourceURL) {
                        Label("Go to source", systemImage: "link")
                    }
                }

            } preview: {
                ContextMenuPostPreview(post: post)
            }
            .onAppear {
                viewStore.send(.postAppeared(post))
            }
            .onTapGesture {
                viewStore.send(.openPost(post))
            }
    }

    func calculateColumns(availableWidth: CGFloat, preferredItemWidth: CGFloat) -> [GridItem] {
        let itemCount = Int((availableWidth / preferredItemWidth).rounded(.toNearestOrAwayFromZero))
        let item = GridItem(.flexible(), spacing: spacing)
        return Array(repeating: item, count: itemCount)
    }

    // MARK: - Bindings

    var searchTextBinding: Binding<String> {
        viewStore.binding {
            $0.searchText
        } send: {
            .updateSearchText($0)
        }
    }

    var tokenBinding: Binding<IdentifiedArrayOf<TagToken>> {
        viewStore.binding {
            $0.tags
        } send: {
            .updateTags($0)
        }
    }

    var suggestedTokenBinding: Binding<IdentifiedArrayOf<TagToken>> {
        Binding {
            viewStore.suggestedTags
        } set: { _ in
            // Do nothing
        }
    }

    var isFilterEditorPresented: Binding<Bool> {
        viewStore.binding { state in
            state.filterEditorState != nil
        } send: { newValue in
            newValue ? .presentFilters : .dismissFilters
        }
    }

    var isPostDetailPresented: Binding<Bool> {
        viewStore.binding { state in
            state.postDetailState != nil
        } send: { newValue in
            .dismissPost
        }
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

    fileprivate var isDoingInitialLoading: Bool {
        switch (posts.isEmpty, feedPhase) {
        case (true, .idle), (true, .loading):
            return true

        default:
            return false
        }
    }

}