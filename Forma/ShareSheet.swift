import SwiftUI
import UIKit

// MARK: - Native iOS Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // Exclude irrelevant activities
        vc.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
        ]
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
