import SwiftUI
import ComposableArchitecture
import SankakuAPI

struct MainFeedView: View {

    // MARK: - Internal Types

    typealias ViewStore = ComposableArchitecture.ViewStore<MainFeedView.State, MainFeedFeature.Action>

    // MARK: - Internal Properties

    let store: StoreOf<MainFeedFeature>
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
        WithViewStore(store, observe: State.init) { viewStore in
            body(viewStore: viewStore)
        }
    }

    func body(viewStore: ViewStore) -> some View {
        feed(viewStore: viewStore)
            .onAppear {
                viewStore.send(.appear)
            }
            .searchable(
                text: searchText(viewStore: viewStore),
                tokens: tokens(viewStore: viewStore),
                suggestedTokens: suggestedTokens(viewStore: viewStore),
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
            .sheet(isPresented: isFilterEditorPresented(viewStore: viewStore)) {
                IfLetStore(store.scope(state: { $0.filterEditorState }, action: { .filterEditor($0) })) { store in
                    FilterEditorView(store: store)
                }
            }
            .navigationDestination(isPresented: isPostDetailPresented(viewStore: viewStore)) {
                IfLetStore(store.scope(state: { $0.postDetailState }, action: { .postDetail($0) })) { store in
                    PostDetailView(store: store)
                }
            }
    }

    func feed(viewStore: ViewStore) -> some View {
        ZStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        LazyVGrid(columns: .dynamic(availableWidth: gr.size.width, spacing: spacing), spacing: spacing) {
                            ForEach(viewStore.posts) { post in
                                item(viewStore: viewStore, post: post)
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

    func item(viewStore: ViewStore, post: Post) -> some View {
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

    // MARK: - Bindings

    func searchText(viewStore: ViewStore) -> Binding<String> {
        viewStore.binding {
            $0.searchText
        } send: {
            .updateSearchText($0)
        }
    }

    func tokens(viewStore: ViewStore) -> Binding<IdentifiedArrayOf<TagToken>> {
        viewStore.binding {
            $0.tags
        } send: {
            .updateTags($0)
        }
    }

    func suggestedTokens(viewStore: ViewStore) -> Binding<IdentifiedArrayOf<TagToken>> {
        Binding {
            viewStore.suggestedTags
        } set: { _ in
            // Do nothing
        }
    }

    func isFilterEditorPresented(viewStore: ViewStore) -> Binding<Bool> {
        viewStore.binding { state in
            state.isFilterEditorPresented
        } send: { newValue in
            newValue ? .presentFilters : .dismissFilters
        }
    }

    func isPostDetailPresented(viewStore: ViewStore) -> Binding<Bool> {
        viewStore.binding { state in
            state.isPostDetailPresented
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

extension MainFeedView {

    struct State: Equatable {
        let posts: IdentifiedArrayOf<Post>
        let feedPhase: FeedPhase
        let searchText: String
        let tags: IdentifiedArrayOf<TagToken>
        let suggestedTags: IdentifiedArrayOf<TagToken>
        let isFilterEditorPresented: Bool
        let isPostDetailPresented: Bool

        init(featureState: MainFeedFeature.State) {
            self.posts = featureState.posts
            self.feedPhase = featureState.feedPhase
            self.searchText = featureState.searchText
            self.tags = featureState.tags
            self.suggestedTags = featureState.suggestedTags
            self.isFilterEditorPresented = featureState.filterEditorState != nil
            self.isPostDetailPresented = featureState.postDetailState != nil
        }
    }

}

extension MainFeedView.State {

    fileprivate var isDoingInitialLoading: Bool {
        switch (posts.isEmpty, feedPhase) {
        case (true, .idle), (true, .loading):
            return true

        default:
            return false
        }
    }

}
