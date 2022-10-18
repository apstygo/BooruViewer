import SwiftUI
import SDWebImageSwiftUI
import SankakuAPI

struct ContextMenuPostPreview: View {

    let post: Post

    var body: some View {
        WebImage(url: post.sampleURL)
            .resizable()
            .placeholder {
                ProgressView()
                    .frame(width: post.sampleWidth, height: post.sampleHeight)
            }
            .scaledToFit()
    }

}
