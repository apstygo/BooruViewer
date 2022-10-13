import SwiftUI
import ComposableArchitecture
import Kingfisher
import SankakuAPI

struct MainFeedView: View {

    // MARK: - Types

    typealias VStore = ViewStoreOf<MainFeedFeature>

    // MARK: - Internal Properties

    let store: StoreOf<MainFeedFeature>
    @State var numberOfColumns = 3

    var columns: [GridItem] {
        Array(repeating: GridItem(spacing: 2), count: numberOfColumns)
    }

    // MARK: - Views

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(for: viewStore)
        }
    }

    @ViewBuilder
    func content(for viewStore: VStore) -> some View {
        NavigationStack {
            feed(for: viewStore)
        }
    }

    @ViewBuilder
    func feed(for viewStore: VStore) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewStore.posts, id: \.post.id) { post in
                    PostPreview(post: post)
                        .onAppear {
                            viewStore.send(.loadMorePosts(index: post.index))
                        }
                        .onTapGesture {
                            viewStore.send(.presentDetailFeed(post.post))
                        }
                }
            }
            .navigationDestination(
                isPresented: viewStore.binding(
                    get: { $0.detailFeedState != nil },
                    send: .dismissDetailFeed
                )
            ) {
                IfLetStore(store.scope(state: \.detailFeedState, action: { .detailFeedAction($0) })) {
                    DetailFeedView(store: $0)
                }
            }
        }
        .overlay() {
            ProgressView()
                .opacity(viewStore.posts.isEmpty ? 1 : 0)
                .animation(.default, value: viewStore.posts.isEmpty)
        }
        .onAppear { viewStore.send(.appear) }
        .animation(.default, value: viewStore.posts)
        .searchable(
            text: searchQueryBinding(for: viewStore),
            tokens: searchTagsBinding(for: viewStore),
            prompt: Text("Search using tags")
        ) { tag in
            TagView(tag: tag)
        }
        .searchSuggestions {
            ForEach(viewStore.tagSuggestions) { tag in
                TagView(tag: tag)
                    .searchCompletion(tag)
            }
        }
        .refreshable {
            viewStore.send(.reload)
        }
        .textInputAutocapitalization(.never)
        .scrollDismissesKeyboard(.immediately)
    }

    // MARK: - Methods

    func searchQueryBinding(for viewStore: VStore) -> Binding<String> {
        viewStore.binding { state in
            state.searchQuery
        } send: { searchQuery in
            .setSearchQuery(searchQuery)
        }
    }

    func searchTagsBinding(for viewStore: VStore) -> Binding<[Tag]> {
        viewStore.binding { state in
            state.searchTags
        } send: { tags in
            .setSearchTags(tags)
        }
    }

}

private struct PostPreview: View {

    let post: IndexedPost

    var body: some View {
        GeometryReader { gr in
            content
                .frame(width: gr.size.width, height: gr.size.height)
                .clipped()
        }
        .aspectRatio(1, contentMode: .fill)
    }

    @ViewBuilder
    var content: some View {
        if let previewURL = post.post.previewURL {
            KFImage(previewURL)
                .resizable()
                .fade(duration: 0.3)
                .onFailureImage(KFCrossPlatformImage(systemName: "exclamationmark.triangle"))
                .scaledToFill()
        }
        else {
            Image(systemName: "eye.slash")
        }
    }

}

struct MainFeedView_Previews: PreviewProvider {

    static var previews: some View {
        MainFeedView(
            store: Store(
                initialState: MainFeedFeature.State(),
                reducer: MainFeedFeature()
            )
        )
    }

}
