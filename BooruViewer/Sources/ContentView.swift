import SwiftUI
import Kingfisher
import SankakuAPI

struct ContentView: View {

    @ObservedObject var postRepo = PostRepo()
    @GestureState var columnDifference = 0
    @State var numberOfColumns = 3

    var columns: [GridItem] {
        Array(repeating: GridItem(spacing: 2), count: numberOfColumns)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(postRepo.postPreviews, id: \.id) { post in
                    PostPreview(post: post)
                        .onAppear {
                            Task {
                                try await postRepo.loadMorePosts(for: post.index)
                            }
                        }
                }
            }
            .animation(.interactiveSpring(), value: columns.count)
        }
        .gesture(pinch)
        .onAppear {
            Task {
                try await postRepo.loadImages()
            }
        }
    }

    var pinch: some Gesture {
        MagnificationGesture()
            .map { scale -> Int in
                if scale > 1.5 {
                    return -1
                }
                else if scale < 0.5 {
                    return 1
                }
                else {
                    return 0
                }
            }
            .updating($columnDifference) { currentState, gestureState, transaction in
                gestureState = currentState
            }
            .onChanged { diff in
                numberOfColumns = max(min(numberOfColumns + diff, 6), 0)
            }
    }

}

private struct PostPreview: View {

    let post: PostPreviewViewModel

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
        if let previewURL = post.previewURL {
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

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }

}
