import SwiftUI

struct AudioVisualizerView: View {
    let isPlaying: Bool
    @State private var animationValues: [CGFloat] = Array(repeating: 0.1, count: 20)
    @State private var timer: Timer?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<animationValues.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: isPlaying ? [.blue, .purple, .pink] : [.gray.opacity(0.3)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 4, height: animationValues[index] * 60 + 8)
                    .animation(
                        .easeInOut(duration: 0.3).delay(Double(index) * 0.02),
                        value: animationValues[index]
                    )
            }
        }
        .frame(height: 80)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPlaying ? .blue.opacity(0.3) : .clear, lineWidth: 1)
        )
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    private func startAnimation() {
        guard isPlaying else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                for i in 0..<animationValues.count {
                    if isPlaying {
                        animationValues[i] = CGFloat.random(in: 0.2...1.0)
                    } else {
                        animationValues[i] = 0.1
                    }
                }
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        
        withAnimation(.easeOut(duration: 0.5)) {
            for i in 0..<animationValues.count {
                animationValues[i] = 0.1
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioVisualizerView(isPlaying: false)
        AudioVisualizerView(isPlaying: true)
    }
    .padding()
}