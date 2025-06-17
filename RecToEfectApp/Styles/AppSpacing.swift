import SwiftUI

struct AppSpacing {
    // Base Spacing Values
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    
    // Semantic Spacing
    static let elementSpacing = md        // 要素間の標準間隔
    static let sectionSpacing = lg        // セクション間の間隔
    static let screenPadding = lg         // 画面端からの余白
    static let cardPadding = md           // カード内の余白
    static let buttonPadding = md         // ボタン内の余白
    
    // Component-specific Spacing
    static let buttonHeight: CGFloat = 48
    static let buttonHeightLarge: CGFloat = 56
    static let buttonHeightSmall: CGFloat = 36
    
    static let iconSize: CGFloat = 24
    static let iconSizeSmall: CGFloat = 16
    static let iconSizeLarge: CGFloat = 32
    
    static let cornerRadius: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 8
    
    // Audio-specific Spacing
    static let waveformHeight: CGFloat = 80
    static let recordButtonSize: CGFloat = 80
    static let playButtonSize: CGFloat = 44
    static let volumeIndicatorHeight: CGFloat = 120
}