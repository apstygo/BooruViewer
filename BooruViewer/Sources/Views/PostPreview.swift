import SwiftUI
import SDWebImageSwiftUI
import SankakuAPI

struct PostPreview: View {

    let post: Post

    var body: some View {
        GeometryReader { gr in
            WebImage(url: post.previewURL)
                .resizable()
                .placeholder {
                    PostPreviewPlaceholder()
                }
                .scaledToFill()
                .frame(width: gr.size.width, height: gr.size.height)
                .clipped()
        }
    }

}

struct PostPreviewPlaceholder: View {

    @State var opacity: Double = 0

    var body: some View {
        Rectangle()
            .foregroundColor(.gray)
            .opacity(opacity)
            .animation(animation, value: opacity)
            .onAppear {
                opacity = 0.5
            }
    }

    var animation: Animation {
        .linear(duration: 1).repeatForever(autoreverses: true)
    }

}
