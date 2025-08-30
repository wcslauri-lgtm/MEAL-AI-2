import SwiftUI

struct AnalysisOverlayView: View {
    let onCancel: (() -> Void)?
    @State private var step = 0
    private let steps = [
        "Optimizing your image…",
        "Encoding image data…",
        "Preparing API request…",
        "Sending request to OpenAI…",
        "AI is cooking up results…"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Analyzing food with AI…").font(.headline)
            ProgressView()
            VStack(alignment: .leading, spacing: 6) {
                ForEach(steps.indices, id: \.self) { idx in
                    HStack {
                        Image(systemName: idx < step ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(idx < step ? .green : .secondary)
                        Text(steps[idx]).font(.footnote)
                    }
                }
            }
            if let cancel = onCancel {
                Button("Cancel", action: cancel)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear { advance() }
    }

    private func advance() {
        guard step < steps.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            step += 1
            advance()
        }
    }
}
