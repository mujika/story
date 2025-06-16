import SwiftUI

struct MainView: View {
    @StateObject private var audioRecorder = AudioRecorderViewModel()
    @State private var showingSettings = false
    @State private var showingTutorial = false
    @State private var showingRecordList = false
    
    var body: some View {
        ZStack {
            // Background Image
            BackgroundImageView()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Status Indicator Area
                VStack(spacing: 10) {
                    // Spinner Animation
                    SpinnerView(
                        isAnimating: audioRecorder.isRecording || audioRecorder.isPlaying,
                        size: 80
                    )
                    
                    // Volume Level Indicator
                    VolumeIndicator(level: audioRecorder.volumeLevel)
                        .frame(width: 200, height: 20)
                        .opacity(audioRecorder.isRecording ? 1.0 : 0.0)
                        .animation(.easeInOut, value: audioRecorder.isRecording)
                }
                
                // Effect Controls
                EffectControlView(audioRecorder: audioRecorder)
                    .padding(.horizontal)
                
                // Waveform View
                WaveformView(
                    waveformData: audioRecorder.isRecording ? audioRecorder.waveformData : audioRecorder.playbackWaveformData,
                    isRecording: audioRecorder.isRecording,
                    isPlaying: audioRecorder.isPlaying
                )
                .frame(height: 100)
                .padding(.horizontal)
                
                // Control Buttons
                HStack(spacing: 40) {
                    // Record Button
                    RecordButtonView(
                        isRecording: audioRecorder.isRecording,
                        action: {
                            if audioRecorder.isRecording {
                                audioRecorder.stopRecording()
                            } else {
                                audioRecorder.startRecording()
                            }
                        }
                    )
                    
                    // Play Button
                    PlayButtonView(
                        isPlaying: audioRecorder.isPlaying,
                        action: {
                            if audioRecorder.isPlaying {
                                audioRecorder.stopPlayback()
                            } else {
                                audioRecorder.startPlayback()
                            }
                        }
                    )
                    .disabled(audioRecorder.isRecording)
                }
                
                // Playback Progress
                if audioRecorder.duration > 0 {
                    VStack {
                        ProgressView(value: audioRecorder.currentTime, total: audioRecorder.duration)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                        
                        HStack {
                            Text(formatTime(audioRecorder.currentTime))
                            Spacer()
                            Text(formatTime(audioRecorder.duration))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Status Display
                VStack(spacing: 8) {
                    // Description Label
                    Text(audioRecorder.descript)
                        .font(.system(size: 17))
                        .foregroundColor(Color(red: 0.965, green: 0.965, blue: 0.965))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    // Activity Indicator
                    if audioRecorder.isRecording || audioRecorder.isPlaying {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(audioRecorder.isRecording || audioRecorder.isPlaying ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: audioRecorder.isRecording || audioRecorder.isPlaying)
                            
                            Text(audioRecorder.isRecording ? "録音中" : "再生中")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .frame(height: 50)
                .padding(.bottom, 20)
                
                // Bottom Navigation Bar
                HStack(spacing: 20) {
                    // Tutorial Button
                    Button(action: { showingTutorial = true }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "questionmark.circle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            Text("チュートリアル")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // History Button
                    Button(action: { showingRecordList = true }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "list.bullet")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            Text("録音音源")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Settings Button
                    Button(action: { showingSettings = true }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            Text("設定")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
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
