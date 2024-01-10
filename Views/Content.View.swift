import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: DetailView()) {
                    Text("Go to Detail View")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // This space intentionally left blank to hide the back button
                }
            }
        }
    }
}
