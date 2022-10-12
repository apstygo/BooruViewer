import SwiftUI
import ComposableArchitecture
import Kingfisher

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
            feed(for: viewStore)
        }
    }

    @ViewBuilder
    func feed(for viewStore: VStore) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewStore.posts, id: \.post.id) { post in
                    NavigationLink(value: post.post) {
                        PostPreview(post: post)
                            .onAppear {
                                viewStore.send(.loadMorePosts(index: post.index))
                            }
                    }
                }
            }
        }
        .onAppear { viewStore.send(.appear) }
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
