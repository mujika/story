import SwiftUI

struct MainView: View {
    @StateObject private var audioRecorder = AudioRecorderViewModel()
    @State private var showingSettings = false
    @State private var showingTutorial = false
    @State private var showingRecordList = false
    
    var body: some View {
        ZStack {
            // Background with unified gradient
            AppColors.warmGradient
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.sectionSpacing) {
                Spacer()
                
                // Status Indicator Area
                VStack(spacing: AppSpacing.md) {
                    // Spinner Animation
                    SpinnerView(
                        isAnimating: audioRecorder.isRecording || audioRecorder.isPlaying,
                        size: AppSpacing.recordButtonSize
                    )
                    
                    // Volume Level Indicator
                    VolumeIndicator(level: audioRecorder.volumeLevel)
                        .frame(width: 200, height: 20)
                        .opacity(audioRecorder.isRecording ? 1.0 : 0.0)
                        .animation(.easeInOut, value: audioRecorder.isRecording)
                }
                
                // Effect Controls Card
                CardView(style: .glassMorphism) {
                    EffectControlView(audioRecorder: audioRecorder)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                
                // Waveform Card
                AudioCard(isActive: audioRecorder.isRecording || audioRecorder.isPlaying) {
                    WaveformView(
                        waveformData: audioRecorder.isRecording ? audioRecorder.waveformData : audioRecorder.playbackWaveformData,
                        isRecording: audioRecorder.isRecording,
                        isPlaying: audioRecorder.isPlaying
                    )
                    .frame(height: AppSpacing.waveformHeight)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                
                // Control Buttons
                HStack(spacing: AppSpacing.xl) {
                    // Record Button
                    CircularButton(
                        systemImage: audioRecorder.isRecording ? "stop.fill" : "record.circle",
                        size: .large,
                        isActive: audioRecorder.isRecording
                    ) {
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                        } else {
                            audioRecorder.startRecording()
                        }
                    }
                    
                    // Play Button
                    CircularButton(
                        systemImage: audioRecorder.isPlaying ? "stop.fill" : "play.fill",
                        size: .large,
                        isActive: audioRecorder.isPlaying
                    ) {
                        if audioRecorder.isPlaying {
                            audioRecorder.stopPlayback()
                        } else {
                            audioRecorder.startPlayback()
                        }
                    }
                    .disabled(audioRecorder.isRecording)
                    .opacity(audioRecorder.isRecording ? 0.5 : 1.0)
                }
                
                // Playback Progress
                if audioRecorder.duration > 0 {
                    GlassMorphismCard {
                        VStack(spacing: AppSpacing.sm) {
                            ProgressView(value: audioRecorder.currentTime, total: audioRecorder.duration)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.secondary))
                            
                            HStack {
                                Text(formatTime(audioRecorder.currentTime))
                                    .font(AppTypography.timer)
                                Spacer()
                                Text(formatTime(audioRecorder.duration))
                                    .font(AppTypography.timer)
                            }
                            .foregroundColor(AppColors.onSurface)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                Spacer()
                
                // Status Display
                VStack(spacing: AppSpacing.sm) {
                    Text(audioRecorder.descript)
                        .font(AppTypography.headlineSmall)
                        .foregroundColor(AppColors.onSurface)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    // Activity Indicator
                    if audioRecorder.isRecording || audioRecorder.isPlaying {
                        HStack(spacing: AppSpacing.xs) {
                            Circle()
                                .fill(audioRecorder.isRecording ? AppColors.recordingActive : AppColors.playbackActive)
                                .frame(width: 8, height: 8)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: audioRecorder.isRecording || audioRecorder.isPlaying)
                            
                            Text(audioRecorder.isRecording ? "録音中" : "再生中")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.onSurfaceSecondary)
                        }
                    }
                }
                .frame(height: 50)
                .padding(.bottom, AppSpacing.lg)
                
                // Bottom Navigation Bar
                HStack(spacing: AppSpacing.lg) {
                    NavigationButton(
                        icon: "questionmark.circle",
                        title: "チュートリアル"
                    ) {
                        showingTutorial = true
                    }
                    
                    NavigationButton(
                        icon: "list.bullet",
                        title: "録音音源"
                    ) {
                        showingRecordList = true
                    }
                    
                    NavigationButton(
                        icon: "gearshape",
                        title: "設定"
                    ) {
                        showingSettings = true
                    }
                }
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingView()
        }
        .sheet(isPresented: $showingTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $showingRecordList) {
            AudioRecordListView()
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MainView()
}
