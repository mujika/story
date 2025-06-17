import SwiftUI

struct AppColors {
    // Primary Colors - 音楽アプリらしい温かみのある赤系
    static let primary = Color(red: 177/255, green: 23/255, blue: 23/255)
    static let primaryLight = Color(red: 200/255, green: 60/255, blue: 60/255)
    static let primaryDark = Color(red: 140/255, green: 18/255, blue: 18/255)
    
    // Secondary Colors - 補完色（青緑系）
    static let secondary = Color(red: 23/255, green: 177/255, blue: 150/255)
    static let secondaryLight = Color(red: 60/255, green: 200/255, blue: 180/255)
    
    // Accent Colors - アクセント用
    static let accent = Color.blue
    static let accentSuccess = Color.green
    static let accentWarning = Color.orange
    static let accentError = Color.red
    
    // Neutral Colors
    static let surface = Color.white.opacity(0.1)
    static let surfaceElevated = Color.white.opacity(0.15)
    static let onSurface = Color.white
    static let onSurfaceSecondary = Color.white.opacity(0.8)
    static let onSurfaceTertiary = Color.white.opacity(0.6)
    
    // Background Colors
    static let background = Color.black
    static let backgroundSecondary = Color.black.opacity(0.8)
    
    // Gradients - 音楽アプリらしいグラデーション
    static let primaryGradient = LinearGradient(
        colors: [primary.opacity(0.8), background.opacity(0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [
            Color(red: 177/255, green: 23/255, blue: 23/255).opacity(0.7),
            Color(red: 255/255, green: 94/255, blue: 77/255).opacity(0.5),
            Color.black.opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [surface, surfaceElevated],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Audio-specific Colors
    static let recordingActive = Color.red
    static let playbackActive = secondary
    static let waveformRecording = primary
    static let waveformPlayback = secondary
}