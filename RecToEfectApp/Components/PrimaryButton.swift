import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let size: ButtonSize
    
    init(
        _ title: String,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(AppColors.onSurface)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background(
                    LinearGradient(
                        colors: isEnabled ? [AppColors.primary, AppColors.primaryDark] : [AppColors.onSurfaceTertiary, AppColors.onSurfaceTertiary.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(AppSpacing.cornerRadius)
                .shadow(
                    color: isEnabled ? AppColors.primary.opacity(0.3) : .clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let size: ButtonSize
    
    init(
        _ title: String,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(isEnabled ? AppColors.onSurface : AppColors.onSurfaceTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background(AppColors.surface)
                .cornerRadius(AppSpacing.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                        .stroke(AppColors.onSurface.opacity(0.2), lineWidth: 1)
                )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

struct CircularButton: View {
    let systemImage: String
    let action: () -> Void
    let isActive: Bool
    let size: CircularButtonSize
    
    init(
        systemImage: String,
        size: CircularButtonSize = .medium,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.isActive = isActive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isActive ? [AppColors.recordingActive, AppColors.primaryDark] : [AppColors.secondary, AppColors.secondaryLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.diameter, height: size.diameter)
                    .shadow(
                        color: (isActive ? AppColors.recordingActive : AppColors.secondary).opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                
                Image(systemName: systemImage)
                    .font(.system(size: size.iconSize, weight: .bold))
                    .foregroundColor(AppColors.onSurface)
            }
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Supporting Types
enum ButtonSize {
    case small, medium, large
    
    var height: CGFloat {
        switch self {
        case .small: return AppSpacing.buttonHeightSmall
        case .medium: return AppSpacing.buttonHeight
        case .large: return AppSpacing.buttonHeightLarge
        }
    }
    
    var font: Font {
        switch self {
        case .small: return AppTypography.labelMedium
        case .medium: return AppTypography.button
        case .large: return AppTypography.buttonLarge
        }
    }
}

enum CircularButtonSize {
    case small, medium, large
    
    var diameter: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return AppSpacing.playButtonSize
        case .large: return AppSpacing.recordButtonSize
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 28
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton("Primary Button") { }
        SecondaryButton("Secondary Button") { }
        CircularButton(systemImage: "play.fill") { }
        CircularButton(systemImage: "stop.fill", isActive: true) { }
    }
    .padding()
    .background(AppColors.background)
}