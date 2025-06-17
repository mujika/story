import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    let style: CardStyle
    let padding: CGFloat
    
    init(
        style: CardStyle = .standard,
        padding: CGFloat = AppSpacing.cardPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(style.background)
            .cornerRadius(style.cornerRadius)
            .shadow(
                color: style.shadowColor,
                radius: style.shadowRadius,
                x: 0,
                y: style.shadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
    }
}

struct GlassMorphismCard<Content: View>: View {
    let content: Content
    let blur: CGFloat
    let opacity: Double
    
    init(
        blur: CGFloat = 10,
        opacity: Double = 0.1,
        @ViewBuilder content: () -> Content
    ) {
        self.blur = blur
        self.opacity = opacity
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                    .fill(AppColors.onSurface.opacity(opacity))
                    .background(.ultraThinMaterial)
            )
            .cornerRadius(AppSpacing.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.onSurface.opacity(0.3),
                                AppColors.onSurface.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct AudioCard<Content: View>: View {
    let content: Content
    let isActive: Bool
    
    init(
        isActive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.isActive = isActive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .fill(AppColors.surface)
                    .shadow(
                        color: AppColors.background.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .stroke(
                        isActive ? AppColors.secondary.opacity(0.6) : AppColors.onSurface.opacity(0.1),
                        lineWidth: isActive ? 2 : 1
                    )
            )
            .scaleEffect(isActive ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Card Styles
enum CardStyle {
    case standard
    case elevated
    case outlined
    case glassMorphism
    
    var background: AnyView {
        switch self {
        case .standard:
            return AnyView(AppColors.surface)
        case .elevated:
            return AnyView(AppColors.surfaceElevated)
        case .outlined:
            return AnyView(Color.clear)
        case .glassMorphism:
            return AnyView(AppColors.surface.opacity(0.3))
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .glassMorphism:
            return AppSpacing.cornerRadiusLarge
        default:
            return AppSpacing.cornerRadius
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .outlined, .glassMorphism:
            return .clear
        default:
            return AppColors.background.opacity(0.3)
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .elevated:
            return 8
        case .standard:
            return 4
        default:
            return 0
        }
    }
    
    var shadowY: CGFloat {
        switch self {
        case .elevated:
            return 4
        case .standard:
            return 2
        default:
            return 0
        }
    }
    
    var borderColor: Color {
        switch self {
        case .outlined:
            return AppColors.onSurface.opacity(0.2)
        case .glassMorphism:
            return AppColors.onSurface.opacity(0.1)
        default:
            return .clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outlined, .glassMorphism:
            return 1
        default:
            return 0
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: AppSpacing.md) {
            CardView {
                VStack {
                    Text("Standard Card")
                        .headlineText()
                    Text("This is a standard card with default styling")
                        .secondaryText()
                }
            }
            
            CardView(style: .elevated) {
                Text("Elevated Card")
                    .headlineText()
            }
            
            GlassMorphismCard {
                VStack {
                    Text("Glass Morphism")
                        .headlineText()
                    Text("Modern glass effect")
                        .secondaryText()
                }
            }
            
            AudioCard(isActive: true) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(AppColors.secondary)
                    Text("Active Audio Card")
                        .headlineText()
                    Spacer()
                }
            }
        }
        .padding()
    }
    .background(AppColors.primaryGradient)
}