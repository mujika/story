import SwiftUI

struct EffectControlView: View {
    @ObservedObject var audioRecorder: AudioRecorderViewModel
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("エフェクト")
                .font(AppTypography.headlineMedium)
                .foregroundColor(AppColors.onSurface)
                .padding(.top, AppSpacing.sm)
            
            VStack(spacing: AppSpacing.md) {
                // Reverb Control
                EffectControlCard(
                    title: "リバーブ",
                    isEnabled: audioRecorder.reverbEnabled,
                    toggleColor: AppColors.accent,
                    onToggle: { audioRecorder.toggleReverb() }
                ) {
                    if audioRecorder.reverbEnabled {
                        EffectSlider(
                            title: "深さ",
                            value: Binding(
                                get: { audioRecorder.reverbWetness },
                                set: { audioRecorder.setReverbWetness($0) }
                            ),
                            range: 0...1,
                            step: 0.1,
                            color: AppColors.accent
                        )
                    }
                }
                
                // Delay Control
                EffectControlCard(
                    title: "ディレイ",
                    isEnabled: audioRecorder.delayEnabled,
                    toggleColor: AppColors.secondary,
                    onToggle: { audioRecorder.toggleDelay() }
                ) {
                    if audioRecorder.delayEnabled {
                        EffectSlider(
                            title: "遅延時間",
                            value: Binding(
                                get: { audioRecorder.delayTime },
                                set: { audioRecorder.setDelayTime($0) }
                            ),
                            range: 0.1...1.0,
                            step: 0.1,
                            color: AppColors.secondary,
                            unit: "秒"
                        )
                    }
                }
            }
            
            // Real-time Processing Control
            HStack(spacing: AppSpacing.md) {
                SecondaryButton(
                    "処理開始",
                    size: .small
                ) {
                    audioRecorder.startRealTimeProcessing()
                }
                
                SecondaryButton(
                    "処理停止",
                    size: .small
                ) {
                    audioRecorder.stopRealTimeProcessing()
                }
            }
            .padding(.bottom, AppSpacing.sm)
        }
    }
}

// MARK: - Supporting Components
struct EffectControlCard<Content: View>: View {
    let title: String
    let isEnabled: Bool
    let toggleColor: Color
    let onToggle: () -> Void
    let content: Content
    
    init(
        title: String,
        isEnabled: Bool,
        toggleColor: Color,
        onToggle: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.toggleColor = toggleColor
        self.onToggle = onToggle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.onSurface)
                
                Spacer()
                
                Toggle("", isOn: .constant(isEnabled))
                    .toggleStyle(SwitchToggleStyle(tint: toggleColor))
                    .onTapGesture { onToggle() }
            }
            
            content
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .cornerRadius(AppSpacing.cornerRadius)
    }
}

struct EffectSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let color: Color
    let unit: String
    
    init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        color: Color,
        unit: String = ""
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.color = color
        self.unit = unit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.onSurfaceSecondary)
                
                Spacer()
                
                if !unit.isEmpty {
                    Text("\(value, specifier: "%.1f")\(unit)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.onSurfaceTertiary)
                }
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(color)
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        EffectControlView(audioRecorder: AudioRecorderViewModel())
    }
    .padding()
    .background(AppColors.warmGradient)
}