import SwiftUI

struct SpinnerView: View {
    let isAnimating: Bool
    let size: CGFloat
    @State private var rotation: Double = 0
    
    init(isAnimating: Bool, size: CGFloat = 70) {
        self.isAnimating = isAnimating
        self.size = size
    }
    
    var body: some View {
        Image("Kurukuru")
            .resizable()
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .opacity(isAnimating ? 1.0 : 0.3)
            .animation(.easeInOut(duration: 0.3), value: isAnimating)
            .onAppear {
                if isAnimating {
                    startAnimation()
                }
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            rotation = 0
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpinnerView(isAnimating: true)
        SpinnerView(isAnimating: false)
    }
    .padding()
    .background(Color.black)
}