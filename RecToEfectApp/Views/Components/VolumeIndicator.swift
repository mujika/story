import SwiftUI

struct VolumeIndicator: View {
    let level: Float
    let numberOfBars: Int = 20
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(colorForBar(at: index))
                    .frame(width: 8, height: heightForBar(at: index))
                    .animation(.easeInOut(duration: 0.1), value: level)
            }
        }
    }
    
    private func heightForBar(at index: Int) -> CGFloat {
        let threshold = Float(index) / Float(numberOfBars)
        return level > threshold ? 20 : 8
    }
    
    private func colorForBar(at index: Int) -> Color {
        let threshold = Float(index) / Float(numberOfBars)
        
        if level <= threshold {
            return Color.gray.opacity(0.3)
        }
        
        // Color gradient from green to yellow to red
        switch threshold {
        case 0.0..<0.6:
            return Color.green
        case 0.6..<0.8:
            return Color.yellow
        default:
            return Color.red
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VolumeIndicator(level: 0.0)
        VolumeIndicator(level: 0.3)
        VolumeIndicator(level: 0.6)
        VolumeIndicator(level: 0.9)
    }
    .padding()
    .background(Color.black)
}