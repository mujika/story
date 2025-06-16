import SwiftUI
import AVFoundation
import SwiftData
import Combine

@MainActor
class AudioRecorderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var descript: String = ""
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var volumeLevel: Float = 0.0
    
    // MARK: - Audio Properties
    private var audioEngine: AVAudioEngine!
    private var audioEngineMix: AVAudioEngine!
    private var audioFile: AVAudioFile!
    private var audioFilePlayer: AVAudioPlayerNode!
    private var outref: ExtAudioFileRef?
    private var mixer: AVAudioMixerNode!
    private var format: AVAudioFormat!
    
    // MARK: - Audio Configuration
    private let sampleRate = 44100.0
    private let bufferDuration: TimeInterval = 0.004
    private var offset: Double = 0.0
    private var filePath: String?
    private var waveFormPath: String?
    
    
    // MARK: - SwiftData Properties
    private let dataManager = DataManager.shared
    @Published var audioRecords: [AudioRecord] = []
    
    // MARK: - UI State
    private var touchBool = true
    private var volumeSet = 0.0
    private var kanshi = 0
    private var seekCheck = true
    
    // MARK: - Timer
    private var playbackTimer: Timer?
    
    init() {
        setupAudio()
        loadAudioRecords()
    }
    
    // MARK: - Setup Methods
    private func setupAudio() {
        audioEngine = AVAudioEngine()
        audioEngineMix = AVAudioEngine()
        audioFilePlayer = AVAudioPlayerNode()
        mixer = AVAudioMixerNode()
        
        // Audio session setup
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            // 入力ノードのフォーマットを取得
            let inputNode = audioEngine.inputNode
            let inputFormat = inputNode.inputFormat(forBus: 0)
            
            // 録音フォーマットを入力フォーマットに合わせる
            format = AVAudioFormat(
                commonFormat: inputFormat.commonFormat,
                sampleRate: inputFormat.sampleRate,
                channels: inputFormat.channelCount,
                interleaved: inputFormat.isInterleaved
            )
            
        } catch {
            print("Audio session setup error: \(error)")
        }
    }
    
    private func loadAudioRecords() {
        Task { @MainActor in
            do {
                audioRecords = try dataManager.fetchAllAudioRecords()
            } catch {
                print("Failed to load audio records: \(error)")
            }
        }
    }
    
    // MARK: - Recording Methods
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).caf")
            filePath = audioURL.path
            
            audioFile = try AVAudioFile(forWriting: audioURL, settings: format.settings)
            
            let inputNode = audioEngine.inputNode
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
                try? self?.audioFile.write(from: buffer)
                
                // Volume level calculation
                DispatchQueue.main.async {
                    self?.updateVolumeLevel(from: buffer)
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isRecording = true
                self.descript = "録音中..."
            }
            
        } catch {
            print("Recording start error: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Save to SwiftData
        saveAudioToSwiftData()
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.descript = "録音完了"
        }
    }
    
    // MARK: - Playback Methods
    func startPlayback() {
        guard !isPlaying, let path = filePath else { return }
        
        do {
            let audioURL = URL(fileURLWithPath: path)
            audioFile = try AVAudioFile(forReading: audioURL)
            duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            
            audioFilePlayer = AVAudioPlayerNode()
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioFilePlayer, to: audioEngine.outputNode, format: audioFile.processingFormat)
            
            audioFilePlayer.scheduleFile(audioFile, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    self?.stopPlayback()
                }
            }
            
            try audioEngine.start()
            audioFilePlayer.play()
            
            DispatchQueue.main.async {
                self.isPlaying = true
                self.startPlaybackTimer()
            }
            
        } catch {
            print("Playback start error: \(error)")
        }
    }
    
    func stopPlayback() {
        guard isPlaying else { return }
        
        audioFilePlayer?.stop()
        audioEngine.stop()
        playbackTimer?.invalidate()
        
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0.0
        }
    }
    
    // MARK: - Helper Methods
    private func updateVolumeLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frames = buffer.frameLength
        var sum: Float = 0.0
        
        for i in 0..<Int(frames) {
            sum += abs(channelData[i])
        }
        
        let averageAmplitude = sum / Float(frames)
        volumeLevel = averageAmplitude
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.isPlaying {
                    self.currentTime += 0.1
                    if self.currentTime >= self.duration {
                        self.stopPlayback()
                    }
                }
            }
        }
    }
    
    private func saveAudioToSwiftData() {
        guard let path = filePath else { return }
        
        Task { @MainActor in
            let audioRecord = AudioRecord(
                audioTitle: "Recording \(Date().formatted(.dateTime.hour().minute()))",
                audioPath: path,
                duration: duration
            )
            
            do {
                try dataManager.saveAudioRecord(audioRecord)
                audioRecords = try dataManager.fetchAllAudioRecords()
            } catch {
                print("SwiftData save error: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    func deleteRecord(_ record: AudioRecord) {
        Task { @MainActor in
            do {
                // ファイルも削除
                if FileManager.default.fileExists(atPath: record.audioPath) {
                    try FileManager.default.removeItem(atPath: record.audioPath)
                }
                
                try dataManager.deleteAudioRecord(record)
                audioRecords = try dataManager.fetchAllAudioRecords()
            } catch {
                print("Delete record error: \(error)")
            }
        }
    }
    
    deinit {
        playbackTimer?.invalidate()
    }
}
