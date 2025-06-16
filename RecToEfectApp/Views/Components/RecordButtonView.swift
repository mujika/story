import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let action: () -> Void
    
    @State private var animationAmount: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring with pulse animation when recording
                Circle()
                    .stroke(
                        isRecording ? Color.red : Color.gray,
                        lineWidth: 3
                    )
                    .scaleEffect(isRecording ? animationAmount : 1.0)
                    .opacity(isRecording ? (2 - animationAmount) : 1.0)
                    .frame(width: 80, height: 80)
                
                // Inner circle - changes shape when recording
                RoundedRectangle(
                    cornerRadius: isRecording ? 8 : 40
                )
                .fill(isRecording ? Color.red : Color.white)
                .frame(
                    width: isRecording ? 30 : 60,
                    height: isRecording ? 30 : 60
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    animationAmount = 1.3
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animationAmount = 1.0
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 30) {
        RecordButtonView(isRecording: false) {
            print("Start recording")
        }
        
        RecordButtonView(isRecording: true) {
            print("Stop recording")
        }
    }
    .padding()
    .background(Color.black)
}