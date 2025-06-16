import Foundation
import SwiftData

@Model
class AudioRecord {
    @Attribute(.unique) var id: String = UUID().uuidString
    var audioTitle: String = ""
    var audioPath: String = ""
    var createDate: Date = Date()
    var duration: TimeInterval = 0.0
    
    // Relationship with waveform data
    @Relationship(deleteRule: .cascade) var waveformData: WaveformRecord?
    
    init(audioTitle: String = "", audioPath: String = "", duration: TimeInterval = 0.0) {
        self.audioTitle = audioTitle
        self.audioPath = audioPath
        self.duration = duration
        self.createDate = Date()
    }
}