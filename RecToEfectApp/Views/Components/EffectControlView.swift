import SwiftUI

struct EffectControlView: View {
    @ObservedObject var audioRecorder: AudioRecorderViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("エフェクト")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            VStack(spacing: 15) {
                // Reverb Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("リバーブ")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { audioRecorder.reverbEnabled },
                            set: { _ in audioRecorder.toggleReverb() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    if audioRecorder.reverbEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("深さ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Slider(
                                value: Binding(
                                    get: { audioRecorder.reverbWetness },
                                    set: { audioRecorder.setReverbWetness($0) }
                                ),
                                in: 0...1,
                                step: 0.1
                            )
                            .accentColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Delay Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ディレイ")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { audioRecorder.delayEnabled },
                            set: { _ in audioRecorder.toggleDelay() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    
                    if audioRecorder.delayEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("遅延時間")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Slider(
                                value: Binding(
                                    get: { audioRecorder.delayTime },
                                    set: { audioRecorder.setDelayTime($0) }
                                ),
                                in: 0.1...1.0,
                                step: 0.1
                            )
                            .accentColor(.green)
                            
                            Text("\(audioRecorder.delayTime, specifier: "%.1f")秒")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Real-time Processing Control
            HStack(spacing: 20) {
                Button(action: {
                    audioRecorder.startRealTimeProcessing()
                }) {
                    Text("リアルタイム処理開始")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    audioRecorder.stopRealTimeProcessing()
                }) {
                    Text("処理停止")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.6))
                        .cornerRadius(8)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
}

#Preview {
    EffectControlView(audioRecorder: AudioRecorderViewModel())
        .background(Color.black)
}