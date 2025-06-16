import SwiftUI

struct PlayButtonView: View {
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                // Play/Pause icon
                Group {
                    if isPlaying {
                        // Pause icon (two rectangles)
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 4, height: 16)
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 4, height: 16)
                        }
                    } else {
                        // Play icon (triangle)
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .offset(x: 2) // Slight offset to center the triangle
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isPlaying)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: 30) {
        PlayButtonView(isPlaying: false) {
            print("Start playing")
        }
        
        PlayButtonView(isPlaying: true) {
            print("Stop playing")
        }
    }
    .padding()
    .background(Color.black)
}