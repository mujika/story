import SwiftUI
import SwiftData

struct AudioRecordListView: View {
    @Query(sort: \AudioRecord.createDate, order: .reverse) 
    private var audioRecords: [AudioRecord]
    
    @Environment(\.modelContext) private var modelContext
    @State private var selectedRecord: AudioRecord?
    @StateObject private var audioPlayer = AudioRecorderViewModel()
    
    var body: some View {
        NavigationView {
            if audioRecords.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "mic.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("録音がありません")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("録音ボタンを押して\n最初の録音を始めましょう")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
                .navigationTitle("録音履歴")
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(audioRecords) { record in
                            AudioRecordCardRow(
                                record: record,
                                isPlaying: audioPlayer.isPlaying && audioPlayer.filePath == record.audioPath,
                                onTap: {
                                    selectedRecord = record
                                },
                                onPlayTap: {
                                    if audioPlayer.isPlaying && audioPlayer.filePath == record.audioPath {
                                        audioPlayer.stopPlayback()
                                    } else {
                                        audioPlayer.playAudioFile(path: record.audioPath)
                                        audioPlayer.filePath = record.audioPath
                                    }
                                }
                            )
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
                .background(AppColors.warmGradient)
                .navigationTitle("録音履歴 (\(audioRecords.count)件)")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                })
            }
        }
        .sheet(item: $selectedRecord) { record in
            AudioRecordDetailView(record: record)
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let record = audioRecords[index]
                
                // Delete audio file if it exists
                if !record.audioPath.isEmpty {
                    try? FileManager.default.removeItem(atPath: record.audioPath)
                }
                
                modelContext.delete(record)
            }
        }
    }
}

struct AudioRecordCardRow: View {
    let record: AudioRecord
    let isPlaying: Bool
    let onTap: () -> Void
    let onPlayTap: () -> Void
    
    var body: some View {
        AudioCard(isActive: isPlaying) {
            HStack(spacing: AppSpacing.md) {
                // Waveform Icon
                ZStack {
                    Circle()
                        .fill(isPlaying ? AppColors.playbackActive.opacity(0.2) : AppColors.surface)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isPlaying ? AppColors.playbackActive : AppColors.onSurfaceSecondary)
                        .scaleEffect(isPlaying ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isPlaying)
                }
                
                // Content area
                Button(action: onTap) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(record.audioTitle.isEmpty ? "無題の録音" : record.audioTitle)
                            .font(AppTypography.headlineSmall)
                            .lineLimit(1)
                            .foregroundColor(AppColors.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: AppSpacing.sm) {
                            Label(
                                record.createDate.formatted(.dateTime.day().month().hour().minute()),
                                systemImage: "clock"
                            )
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.onSurfaceSecondary)
                            
                            if record.duration > 0 {
                                Divider()
                                    .frame(height: 12)
                                
                                Label(
                                    formatDuration(record.duration),
                                    systemImage: "timer"
                                )
                                .font(AppTypography.duration)
                                .foregroundColor(AppColors.onSurfaceSecondary)
                            }
                            
                            Spacer()
                            
                            if isPlaying {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "speaker.wave.2")
                                        .font(.caption)
                                        .foregroundColor(AppColors.playbackActive)
                                    Text("再生中")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.playbackActive)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Play/Stop button
                CircularButton(
                    systemImage: isPlaying ? "stop.fill" : "play.fill",
                    size: .medium,
                    isActive: isPlaying,
                    action: onPlayTap
                )
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioRecordDetailView: View {
    let record: AudioRecord
    @Environment(\.dismiss) private var dismiss
    @State private var showingTrimView = false
    @StateObject private var audioRecorder = AudioRecorderViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Audio Info Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("録音詳細")
                        .font(.title2)
                        .bold()
                    
                    Group {
                        Label("タイトル: \(record.audioTitle)", systemImage: "text.quote")
                        Label("作成日: \(record.createDate.formatted(.dateTime))", systemImage: "calendar")
                        Label("時間: \(formatDuration(record.duration))", systemImage: "clock")
                        Label("ファイルサイズ: \(getFileSize())", systemImage: "doc")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Action Buttons Section
                VStack(spacing: 15) {
                    Button(action: {
                        showingTrimView = true
                    }) {
                        HStack {
                            Image(systemName: "scissors")
                                .font(.title3)
                            Text("音声を編集")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        shareAudio()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            Text("共有")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        playAudio()
                    }) {
                        HStack {
                            Image(systemName: audioRecorder.isPlaying && audioRecorder.filePath == record.audioPath ? "stop.circle" : "play.circle")
                                .font(.title3)
                            Text(audioRecorder.isPlaying && audioRecorder.filePath == record.audioPath ? "停止" : "再生")
                                .font(.headline)
                        }
                        .foregroundColor(audioRecorder.isPlaying && audioRecorder.filePath == record.audioPath ? .red : .green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((audioRecorder.isPlaying && audioRecorder.filePath == record.audioPath ? Color.red : Color.green).opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("録音詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            })
        }
        .sheet(isPresented: $showingTrimView) {
            AudioEditView(audioRecord: record, audioRecorder: audioRecorder)
        }
    }
    
    private func getFileSize() -> String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: record.audioPath),
              let fileSize = attributes[.size] as? Int64 else {
            return "不明"
        }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    private func shareAudio() {
        // TODO: Implement sharing functionality
        print("Sharing audio: \(record.audioTitle)")
    }
    
    private func playAudio() {
        if audioRecorder.isPlaying && audioRecorder.filePath == record.audioPath {
            audioRecorder.stopPlayback()
        } else {
            audioRecorder.playAudioFile(path: record.audioPath)
            audioRecorder.filePath = record.audioPath
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioRecordListView()
        .modelContainer(DataManager.shared.container)
}