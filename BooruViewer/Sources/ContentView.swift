import SwiftUI

struct ContentView: View {

    let columns = Array(repeating: GridItem(spacing: 0), count: 3)

    @ObservedObject var postRepo = PostRepo()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(postRepo.posts, id: \.id) { postViewModel in
                    PostPreview(postState: postViewModel.state)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
        .onAppear {
            Task {
                try await postRepo.loadImages()
            }
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
