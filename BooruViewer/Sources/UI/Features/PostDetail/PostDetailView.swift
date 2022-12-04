import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import AsyncView
import SwiftUIFlow
import SankakuAPI

struct PostDetailView: View {

    // MARK: - Internal Types

    typealias ViewStore = ViewStoreOf<PostDetailFeature>

    // MARK: - Internal Properties

    let store: StoreOf<PostDetailFeature>

    // MARK: - Layout

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            body(for: viewStore)
        }
    }

    func body(for viewStore: ViewStore) -> some View {
        GeometryReader { gr in
            ScrollView {
                VStack(alignment: .leading) {
                    PostImageView(viewModel: viewStore.post)

                    Group {
                        Text("Tags")
                            .font(.title)

                        VFlow(alignment: .leading, spacing: 8) {
                            ForEach(viewStore.post.tags) { tag in
                                TagView(tag: tag)
                            }
                        }
                    }
                    .padding(.horizontal, 12)

                    recommendedPosts(availableWidth: gr.size.width)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewStore.send(.appear)
        }
    }

    func recommendedPosts(availableWidth: CGFloat) -> some View {
        let store = store.scope { parentState in
            PostGridFeature.State(
                posts: parentState.recommended.posts,
                feedPhase: parentState.recommended.feedPhase
            )
        } action: { (childAction: PostGridFeature.Action) in
            switch childAction {
            case let .postAppeared(post):
                return .recommendedPostAppeared(post)

            case let .openPost(post):
                return .openRecommendedPost(post)
            }
        }

        return PostGridView(store: store, availableWidth: availableWidth)
    }

}

// MARK: - PostImageView

private struct PostImageView: View {

    let viewModel: Post
    @State var progressValue: Float = 0
    @State var progressTotal: Float = 1

    var body: some View {
        WebImage(url: viewModel.sampleURL, options: .highPriority)
            .placeholder {
                placeholder
            }
            .resizable()
            .onProgress { value, total in
                progressValue = Float(value)
                progressTotal = max(0, Float(total))
            }
            .scaledToFit()
    }

    @ViewBuilder
    var placeholder: some View {
        WebImage(url: viewModel.previewURL, options: .highPriority)
            .resizable()
            .scaledToFit()
            .overlay(alignment: .bottom) {
                loadingProgress
            }
    }

    @ViewBuilder
    var loadingProgress: some View {
        ProgressView(value: progressValue, total: progressTotal)
            .tint(.white)
            .opacity(progressValue == progressTotal ? 0 : 1)
            .animation(.default, value: progressValue)
    }

}

// MARK: - Previews

struct PostDetailView_Previews: PreviewProvider {

    static let api = SankakuAPI()

    static func getTopPost() async throws -> Post {
        let response = try await api.getPosts()
        return response.data[0]
    }

    static var previews: some View {
        AsyncView {
            try await getTopPost()
        } content: { post in
            PostDetailView(
                store: Store(
                    initialState: PostDetailFeature.State(post: post),
                    reducer: PostDetailFeature()
                )
            )
        }
    }

}

// MARK: - Helpers

extension Post {

    fileprivate var aspectRatio: CGFloat? {
        guard let sampleWidth, let sampleHeight else {
            return nil
        }

        return sampleWidth / sampleHeight
    }

}
