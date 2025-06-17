import SwiftUI

struct AppTypography {
    // Display Text - 大見出し
    static let displayLarge = Font.system(size: 40, weight: .black, design: .rounded)
    static let displayMedium = Font.system(size: 32, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 28, weight: .bold, design: .rounded)
    
    // Headlines - 見出し
    static let headlineLarge = Font.system(size: 24, weight: .bold, design: .rounded)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
    
    // Body Text - 本文
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .rounded)
    
    // Labels - ラベル
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .rounded)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .rounded)
    static let labelSmall = Font.system(size: 10, weight: .medium, design: .rounded)
    
    // Specialized - 特殊用途
    static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let buttonLarge = Font.system(size: 18, weight: .bold, design: .rounded)
    static let caption = Font.system(size: 11, weight: .regular, design: .rounded)
    static let timer = Font.system(size: 16, weight: .medium, design: .monospaced)
    static let duration = Font.system(size: 14, weight: .medium, design: .monospaced)
}

// MARK: - Text Styles with Colors
extension Text {
    func primaryText() -> some View {
        self.font(AppTypography.bodyLarge)
            .foregroundColor(AppColors.onSurface)
    }
    
    func secondaryText() -> some View {
        self.font(AppTypography.bodyMedium)
            .foregroundColor(AppColors.onSurfaceSecondary)
    }
    
    func captionText() -> some View {
        self.font(AppTypography.caption)
            .foregroundColor(AppColors.onSurfaceTertiary)
    }
    
    func headlineText() -> some View {
        self.font(AppTypography.headlineMedium)
            .foregroundColor(AppColors.onSurface)
    }
    
    func titleText() -> some View {
        self.font(AppTypography.displayMedium)
            .foregroundColor(AppColors.onSurface)
    }
}