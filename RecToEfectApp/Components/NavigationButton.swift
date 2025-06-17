import SwiftUI

struct NavigationButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColors.surface)
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: AppColors.background.opacity(0.3),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppColors.onSurface)
                }
                
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.onSurface)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

#Preview {
    HStack(spacing: AppSpacing.lg) {
        NavigationButton(
            icon: "questionmark.circle",
            title: "チュートリアル"
        ) { }
        
        NavigationButton(
            icon: "list.bullet",
            title: "録音音源"
        ) { }
        
        NavigationButton(
            icon: "gearshape",
            title: "設定"
        ) { }
    }
    .padding()
    .background(AppColors.warmGradient)
}