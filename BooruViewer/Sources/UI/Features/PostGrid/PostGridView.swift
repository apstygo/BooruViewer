import SwiftUI
import ComposableArchitecture
import AsyncView
import SankakuAPI

struct PostGridView: View {

    let store: StoreOf<PostGridFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            PostGridContent(viewStore: viewStore)
        }
    }

}

private struct PostGridContent: View {

    @ObservedObject var viewStore: ViewStoreOf<PostGridFeature>
    let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { gr in
            ScrollView {
                VStack {
                    LazyVGrid(columns: .dynamic(availableWidth: gr.size.width, spacing: spacing), spacing: spacing) {
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

}

// MARK: - Previews

struct PostGridView_Previews: PreviewProvider {

    static func preview(for posts: [Post]) -> some View {
        PostGridView(
            store: Store(
                initialState: PostGridFeature.State(posts: .init(uniqueElements: posts)),
                reducer: PostGridFeature()
            )
        )
    }

    static var previews: some View {
        AsyncView {
            let sankakuAPI = SankakuAPI()
            let response = try await sankakuAPI.getPosts()
            return response.data
        } content: { (posts: [Post]) in
            preview(for: posts)
        }
    }

}

// MARK: - Helpers

extension PostGridFeature.State {

    fileprivate var isDoingInitialLoading: Bool {
        switch (posts.isEmpty, feedPhase) {
        case (true, .idle), (true, .loading):
            return true

        default:
            return false
        }
    }

}
