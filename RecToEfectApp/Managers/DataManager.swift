import Foundation
import SwiftData

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container: ModelContainer
    let context: ModelContext
    
    init() {
        do {
            // Configure the model container
            let schema = Schema([
                AudioRecord.self,
                WaveformRecord.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            context = container.mainContext
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
    
    // MARK: - Audio Record Operations
    
    func saveAudioRecord(_ record: AudioRecord) throws {
        context.insert(record)
        try context.save()
    }
    
    func fetchAllAudioRecords() throws -> [AudioRecord] {
        let descriptor = FetchDescriptor<AudioRecord>(
            sortBy: [SortDescriptor(\.createDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    func deleteAudioRecord(_ record: AudioRecord) throws {
        context.delete(record)
        try context.save()
    }
    
    func updateAudioRecord(_ record: AudioRecord, title: String? = nil, duration: TimeInterval? = nil) throws {
        if let title = title {
            record.audioTitle = title
        }
        if let duration = duration {
            record.duration = duration
        }
        try context.save()
    }
    
    // MARK: - Waveform Record Operations
    
    func saveWaveformRecord(_ record: WaveformRecord, for audioRecord: AudioRecord) throws {
        record.audioRecord = audioRecord
        audioRecord.waveformData = record
        context.insert(record)
        try context.save()
    }
    
    func fetchWaveformRecord(for audioRecord: AudioRecord) -> WaveformRecord? {
        return audioRecord.waveformData
    }
    
    // MARK: - Utility Methods
    
    func deleteAllRecords() throws {
        // 全ての音声録音データを削除
        let audioRecords = try fetchAllAudioRecords()
        for record in audioRecords {
            context.delete(record)
        }
        try context.save()
    }
    
    func getRecordCount() throws -> Int {
        let descriptor = FetchDescriptor<AudioRecord>()
        return try context.fetchCount(descriptor)
    }
}