import SwiftUI
import AVFoundation

struct AudioTrimView: View {
    let audioRecord: AudioRecord
    @ObservedObject var audioRecorder: AudioRecorderViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var startTime: Double = 0.0
    @State private var endTime: Double = 0.0
    @State private var isPlaying: Bool = false
    @State private var playbackPosition: Double = 0.0
    @State private var duration: Double = 0.0
    @State private var waveformData: [Float] = []
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 177/255, green: 23/255, blue: 23/255).opacity(0.7),
                    Color.black.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Navigation Bar
                HStack {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("音声編集")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button("保存") {
                        saveTrimmeedAudio()
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.6))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Audio Title
                Text(audioRecord.audioTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                
                // Waveform with Trim Handles
                VStack(spacing: 15) {
                    // Time Display
                    HStack {
                        Text(formatTime(startTime))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("選択: \(formatTime(endTime - startTime))")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(formatTime(endTime))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                    
                    // Waveform and Trim Controls
                    ZStack {
                        // Background Waveform
                        WaveformView(
                            waveformData: waveformData,
                            isRecording: false,
                            isPlaying: isPlaying
                        )
                        .frame(height: 100)
                        
                        // Trim Range Overlay
                        GeometryReader { geometry in
                            let startX = CGFloat(startTime / duration) * geometry.size.width
                            let endX = CGFloat(endTime / duration) * geometry.size.width
                            
                            // Selected Region
                            Rectangle()
                                .fill(Color.yellow.opacity(0.3))
                                .frame(width: endX - startX)
                                .position(x: startX + (endX - startX) / 2, y: geometry.size.height / 2)
                            
                            // Start Handle
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 3, height: geometry.size.height)
                                .position(x: startX, y: geometry.size.height / 2)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newTime = Double(value.location.x / geometry.size.width) * duration
                                            startTime = max(0, min(newTime, endTime - 0.1))
                                        }
                                )
                            
                            // End Handle
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 3, height: geometry.size.height)
                                .position(x: endX, y: geometry.size.height / 2)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newTime = Double(value.location.x / geometry.size.width) * duration
                                            endTime = max(startTime + 0.1, min(newTime, duration))
                                        }
                                )
                            
                            // Playback Position Indicator
                            if isPlaying {
                                let playX = CGFloat(playbackPosition / duration) * geometry.size.width
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 2, height: geometry.size.height)
                                    .position(x: playX, y: geometry.size.height / 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Trim Range Sliders
                    VStack(spacing: 10) {
                        HStack {
                            Text("開始")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 40, alignment: .leading)
                            
                            Slider(value: $startTime, in: 0...duration) { _ in
                                if startTime >= endTime - 0.1 {
                                    endTime = startTime + 0.1
                                }
                            }
                            .accentColor(.yellow)
                        }
                        
                        HStack {
                            Text("終了")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 40, alignment: .leading)
                            
                            Slider(value: $endTime, in: 0...duration) { _ in
                                if endTime <= startTime + 0.1 {
                                    startTime = endTime - 0.1
                                }
                            }
                            .accentColor(.yellow)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Control Buttons
                HStack(spacing: 30) {
                    Button(action: {
                        playTrimmedSection()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        resetTrimRange()
                    }) {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 30))
                            Text("リセット")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            loadAudioInfo()
        }
    }
    
    private func loadAudioInfo() {
        duration = audioRecord.duration
        endTime = duration
        
        // Load waveform data from audio file
        loadWaveformData()
    }
    
    private func loadWaveformData() {
        // Simplified waveform generation - in production, you'd analyze the actual audio file
        waveformData = Array(repeating: 0.0, count: 50).map { _ in Float.random(in: 0.1...0.8) }
    }
    
    private func playTrimmedSection() {
        isPlaying.toggle()
        // TODO: Implement actual audio playback of trimmed section
        if isPlaying {
            playbackPosition = startTime
            // Start playback timer
        }
    }
    
    private func resetTrimRange() {
        startTime = 0.0
        endTime = duration
    }
    
    private func saveTrimmeedAudio() {
        // TODO: Implement actual audio trimming and saving
        print("Trimming audio from \(startTime) to \(endTime)")
        
        // For now, just dismiss
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioTrimView(
        audioRecord: AudioRecord(
            audioTitle: "Sample Recording",
            audioPath: "/path/to/audio.m4a",
            duration: 120.0
        ),
        audioRecorder: AudioRecorderViewModel()
    )
}