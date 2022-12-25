import SwiftUI
import SDWebImageSwiftUI
#if !os(macOS)
import AsyncView
#endif

struct PostPreview: View {

    let post: Post

    var body: some View {
        ZStack {
            #if canImport(UIKit)
            Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            Color(nsColor: .windowBackgroundColor)
            #endif

            GeometryReader { gr in
                mainContent
                    .scaledToFill()
                    .frame(width: gr.size.width, height: gr.size.height)
                    .clipped()
            }
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Rectangle()) // This fixes incorrect tap area
        }
    }

    @ViewBuilder var mainContent: some View {
        if let url = post.previewURL {
            WebImage(url: url)
                .resizable()
                .placeholder {
                    PostPreviewPlaceholder()
                }
        }
        else {
            UnavailableView(message: "Preview unavailable")
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

#if !os(macOS)
struct PostPreview_Previews: PreviewProvider {

    static var previews: some View {
        AsyncView {
            try await SankakuAPI.getTopPost()
        } content: { post in
            PostPreview(post: post)
        }
    }

}
#endif
