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
    private var audioFilePlayer: AVAudioPlayerNode!
    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    
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
        audioFilePlayer = AVAudioPlayerNode()
        
        // Audio session setup
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            

            
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
            let audioURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
            filePath = audioURL.path

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()

            let inputNode = audioEngine.inputNode
            let format = inputNode.inputFormat(forBus: 0)
            audioEngine.connect(inputNode, to: audioEngine.mainMixerNode, format: format)

            try audioEngine.start()
            audioRecorder?.record()
            startMetering()

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
        
        audioRecorder?.stop()
        meterTimer?.invalidate()
        audioEngine.stop()

        duration = audioRecorder?.currentTime ?? 0

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
            let file = try AVAudioFile(forReading: audioURL)
            duration = Double(file.length) / file.fileFormat.sampleRate

            audioFilePlayer = AVAudioPlayerNode()
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioFilePlayer, to: audioEngine.outputNode, format: file.processingFormat)

            audioFilePlayer.scheduleFile(file, at: nil) { [weak self] in
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
    private func startMetering() {
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            let level = pow(10, power / 20)
            self.volumeLevel = level
        }
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
        meterTimer?.invalidate()
    }
}
