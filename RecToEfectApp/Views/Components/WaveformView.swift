import SwiftUI

struct WaveformView: View {
    let waveformData: [Float]
    let isRecording: Bool
    let isPlaying: Bool
    @State private var animationPhase: Double = 0
    let numberOfBars: Int = 50
    
    var body: some View {
        HStack(alignment: .center, spacing: 1) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(barColor(for: index))
                    .frame(width: 3, height: heightForBar(at: index))
                    .animation(
                        .easeInOut(duration: 0.3),
                        value: heightForBar(at: index)
                    )
            }
        }
        .onAppear {
            if isRecording || isPlaying {
                startAnimation()
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }
    
    private func heightForBar(at index: Int) -> CGFloat {
        if waveformData.isEmpty {
            // フォールバック: アニメーション波形
            let progress = Double(index) / Double(numberOfBars)
            let waveOffset = sin((progress * 4 * .pi) + animationPhase) * 15
            return max(4, 15 + waveOffset)
        } else {
            // 実際の音声データに基づく波形
            let dataIndex = min(index, waveformData.count - 1)
            let amplitude = waveformData[dataIndex]
            let baseHeight: CGFloat = 4
            let maxHeight: CGFloat = 60
            return baseHeight + CGFloat(amplitude) * maxHeight
        }
    }
    
    private func barColor(for index: Int) -> Color {
        if isRecording {
            return AppColors.waveformRecording.opacity(0.8)
        } else if isPlaying {
            return AppColors.waveformPlayback.opacity(0.8)
        } else {
            return AppColors.onSurface.opacity(0.7)
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isRecording && !isPlaying {
                timer.invalidate()
                return
            }
            withAnimation {
                animationPhase += 0.2
            }
        }
    }
}

#Preview {
    WaveformView(
        waveformData: [],
        isRecording: false,
        isPlaying: false
    )
    .frame(height: 100)
    .padding()
    .background(AppColors.background)
}