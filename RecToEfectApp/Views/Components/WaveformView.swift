import SwiftUI

struct WaveformView: View {
    @State private var animationPhase: Double = 0
    let numberOfBars: Int = 50
    
    var body: some View {
        HStack(alignment: .center, spacing: 1) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 3, height: heightForBar(at: index))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .delay(Double(index) * 0.02),
                        value: animationPhase
                    )
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func heightForBar(at index: Int) -> CGFloat {
        let progress = Double(index) / Double(numberOfBars)
        let waveOffset = sin((progress * 4 * .pi) + animationPhase) * 30
        return max(4, 20 + waveOffset)
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation {
                animationPhase += 0.2
            }
        }
    }
}

#Preview {
    WaveformView()
        .frame(height: 100)
        .padding()
        .background(Color.black)
}