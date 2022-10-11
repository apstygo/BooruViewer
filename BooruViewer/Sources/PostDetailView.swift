import SwiftUI
import Kingfisher
import SankakuAPI

struct PostDetailView: View {

    let post: Post

    var body: some View {
        KFImage(post.sampleURL)
            .placeholder { _ in
                KFImage(post.previewURL)
            }
    }

}

//struct PostDetailView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        PostDetailView()
//    }
//
//}
