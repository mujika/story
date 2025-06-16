import Foundation
import SwiftData

@Model
class WaveformRecord {
    @Attribute(.unique) var id: String = UUID().uuidString
    var waveformPath: String = ""
    var createDate: Date = Date()
    
    // Relationship back to audio record
    var audioRecord: AudioRecord?
    
    init(waveformPath: String = "") {
        self.waveformPath = waveformPath
        self.createDate = Date()
    }
}