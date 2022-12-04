import SwiftUI
import ComposableArchitecture
import AsyncView
import SankakuAPI

struct PostGridView: View {

    let store: StoreOf<PostGridFeature>
    let availableWidth: CGFloat

    var body: some View {
        WithViewStore(store) { viewStore in
            PostGridContent(viewStore: viewStore, availableWidth: availableWidth)
        }
    }

}

private struct PostGridContent: View {

    @ObservedObject var viewStore: ViewStoreOf<PostGridFeature>
    let availableWidth: CGFloat
    let spacing: CGFloat = 2

    var body: some View {
        VStack {
            LazyVGrid(columns: .dynamic(availableWidth: availableWidth, spacing: spacing), spacing: spacing) {
                ForEach(viewStore.posts) { post in
                    item(for: post)
                }
            }

            if viewStore.isLoading {
                ProgressView()
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

//                Button {
//                    // Do nothing
//                } label: {
//                    Label("Favorite", systemImage: "heart")
//                }
//                .disabled(true)

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
        GeometryReader { gr in
            ScrollView {
                PostGridView(
                    store: Store(
                        initialState: PostGridFeature.State(posts: .init(uniqueElements: posts)),
                        reducer: PostGridFeature()
                    ),
                    availableWidth: gr.size.width
                )
            }
        }
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

    fileprivate var isLoading: Bool {
        switch feedPhase {
        case .idle, .loading:
            return true

        case .error, .finished:
            return false
        }
    }

}
