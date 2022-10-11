import SwiftUI

struct ContentView: View {

    @ObservedObject var postRepo = PostRepo()
    @GestureState var columnDifference = 0
    @State var numberOfColumns = 3

    var columns: [GridItem] {
        Array(repeating: GridItem(spacing: 0), count: numberOfColumns)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(postRepo.posts, id: \.id) { postViewModel in
                    PostPreview(postState: postViewModel.state)
                        .aspectRatio(1, contentMode: .fill)
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

    let postState: PostRepo.PostState

    var body: some View {
        switch postState {
        case .loading:
            Color.gray

        case let .ready(image):
            GeometryReader { gr in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: gr.size.width, height: gr.size.height)
                    .clipped()
            }

        case .failed:
            Color.red
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }

}
