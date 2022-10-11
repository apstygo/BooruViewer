import SwiftUI

struct ContentView: View {

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @ObservedObject var postRepo = PostRepo()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
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
            Image(uiImage: image)
                .resizable()

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
