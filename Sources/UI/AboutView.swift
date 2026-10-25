import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("LuLu Counts is a free math app for grades 1 to 6. Every topic starts with a short picture lesson, then you practice with hints and stars.")
                    Text("No ads, no purchases, no tracking, no internet. All pictures are drawn inside the app.")
                }
                Section("For parents") {
                    Button("Reset all progress", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .confirmationDialog("Erase all stars and progress?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { progress.reset() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
