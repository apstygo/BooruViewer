import SwiftUI

struct UnavailableView: View {

    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .foregroundColor(.orange)
            .font(.body)
    }

}

struct UnavailableView_Previews: PreviewProvider {

    static var previews: some View {
        UnavailableView(message: "Preview unavailable")
    }

}
