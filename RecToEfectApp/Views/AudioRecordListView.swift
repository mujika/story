import SwiftUI
import SwiftData

struct AudioRecordListView: View {
    @Query(sort: \AudioRecord.createDate, order: .reverse) 
    private var audioRecords: [AudioRecord]
    
    @Environment(\.modelContext) private var modelContext
    @State private var selectedRecord: AudioRecord?
    
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
                List {
                    ForEach(audioRecords) { record in
                        AudioRecordRow(record: record) {
                            selectedRecord = record
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteRecords)
                }
                .listStyle(PlainListStyle())
                .background(Color(UIColor.systemGroupedBackground))
                .navigationTitle("録音履歴 (\(audioRecords.count)件)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
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

struct AudioRecordRow: View {
    let record: AudioRecord
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon area
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            // Content area
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(record.audioTitle.isEmpty ? "無題の録音" : record.audioTitle)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                // Date and duration in a single line
                HStack(spacing: 8) {
                    Label(record.createDate.formatted(.dateTime.day().month().hour().minute()), 
                          systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if record.duration > 0 {
                        Divider()
                            .frame(height: 12)
                        
                        Label(formatDuration(record.duration), 
                              systemImage: "timer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Play button
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 4)
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
                            Image(systemName: "play.circle")
                                .font(.title3)
                            Text("再生")
                                .font(.headline)
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("録音詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingTrimView) {
            AudioTrimView(audioRecord: record, audioRecorder: audioRecorder)
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
        // TODO: Implement audio playback
        print("Playing audio: \(record.audioTitle)")
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