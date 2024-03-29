import SwiftUI
import AVKit
import ComposableArchitecture
import SDWebImageSwiftUI
#if !os(macOS)
import AsyncView
#endif
import SwiftUIFlow

struct PostDetailView: View {

    // MARK: - Internal Types

    typealias ViewStore = ComposableArchitecture.ViewStore<PostDetailView.State, PostDetailFeature.Action>

    // MARK: - Internal Properties

    let store: StoreOf<PostDetailFeature>

    // MARK: - Layout

    var body: some View {
        WithViewStore(store, observe: State.init) { viewStore in
            body(for: viewStore)
        }
    }

    func body(for viewStore: ViewStore) -> some View {
        GeometryReader { gr in
            ScrollView {
                VStack(alignment: .leading) {
                    PostView(post: viewStore.post)

                    Group {
                        sectionHeader("Tags")

                        VFlow(alignment: .leading, spacing: 8) {
                            ForEach(viewStore.post.tags) { tag in
                                TagView(tag: tag)
                                    .onTapGesture {
                                        viewStore.send(.openMainFeedWithTag(tag))
                                    }
                            }
                        }

                        sectionHeader("Recommended posts")
                    }
                    .padding(.horizontal, 12)

                    recommendedPosts(availableWidth: gr.size.width)
                }
            }
        }
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(String(describing: viewStore.post.id))
        .onAppear {
            viewStore.send(.appear)
        }
        .navigationDestination(isPresented: isPostDetailPresented(for: viewStore)) {
            postDetail
        }
        .navigationDestination(isPresented: isMainFeedPresented(for: viewStore)) {
            mainFeed
        }
    }

    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title)
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

    var postDetail: some View {
        let store = store.scope { state in
            state.postDetailState
        } action: { childAction in
            .postDetail(childAction)
        }

        return IfLetStore(store) { store in
            PostDetailView(store: store)
        }
    }

    var mainFeed: some View {
        let store = store.scope { state in
            state.mainFeedState
        } action: { childAction in
            .mainFeed(childAction)
        }

        return IfLetStore(store) { store in
            MainFeedView(store: store)
        }
    }

    // MARK: - Bindings

    func isPostDetailPresented(for viewStore: ViewStore) -> Binding<Bool> {
        viewStore.binding { state in
            state.isPostDetailPresented
        } send: { _ in
            .dismissPost
        }
    }

    func isMainFeedPresented(for viewStore: ViewStore) -> Binding<Bool> {
        viewStore.binding { state in
            state.isMainFeedPresented
        } send: { _ in
            .dismissMainFeed
        }
    }

}

// MARK: - Subviews

private struct PostView: View {

    let post: Post

    var body: some View {
        switch post.fileType {
        case .image:
            PostImageView(viewModel: post)

        case .video:
            PostVideoView(post: post)
        }
    }

}

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

private struct PostVideoView: View {

    let post: Post
    let player: AVQueuePlayer?
    let looper: AVPlayerLooper?

    init(post: Post) {
        self.post = post

        if let url = post.sampleURL {
            let item = AVPlayerItem(url: url)
            let player = AVQueuePlayer(playerItem: item)
            self.player = player
            self.looper = AVPlayerLooper(player: player, templateItem: item)
        }
        else {
            self.player = nil
            self.looper = nil
        }
    }

    var body: some View {
        GeometryReader { gr in
            VideoPlayer(player: player)
                .frame(width: gr.size.width, height: gr.size.width / (post.aspectRatio ?? 1))
                .onAppear {
                    player?.play()
                }
                .onDisappear {
                    player?.pause()
                }
        }
        .aspectRatio(post.aspectRatio, contentMode: .fit)
    }

}

// MARK: - State

extension PostDetailView {

    struct State: Equatable {
        let post: Post
        let isPostDetailPresented: Bool
        let isMainFeedPresented: Bool

        init(featureState: PostDetailFeature.State) {
            self.post = featureState.post
            self.isPostDetailPresented = featureState.postDetailState != nil
            self.isMainFeedPresented = featureState.mainFeedState != nil
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

// MARK: - Previews

#if !os(macOS)
struct PostDetailView_Previews: PreviewProvider {

    static let api = SankakuAPI()

    static var previews: some View {
        AsyncView {
            try await SankakuAPI.getTopPost()
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
#endif
