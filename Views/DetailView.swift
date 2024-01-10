import SwiftUI

struct DetailView: View {
    var body: some View {
        Text("Detail View")
            .navigationTitle("Detail")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // This space intentionally left blank to hide the back button
                }
            }
    }
}

