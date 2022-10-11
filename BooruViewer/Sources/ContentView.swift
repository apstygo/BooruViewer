import SwiftUI

struct ContentView: View {

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(0..<100, id: \.self) { _ in
                    Color.red
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }

}
