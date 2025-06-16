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
    private var audioRecorder: AVAudioRecorder?
    private var audioFile: AVAudioFile!
    private var audioFilePlayer: AVAudioPlayerNode!
    private var mixer: AVAudioMixerNode!
    private var reverbNode: AVAudioUnitReverb!
    private var delayNode: AVAudioUnitDelay!
    private var format: AVAudioFormat!
    
    // MARK: - Audio Configuration
    private let sampleRate = 44100.0
    private let bufferDuration: TimeInterval = 0.004
    private var offset: Double = 0.0
    private var filePath: String?
    private var waveFormPath: String?
    
    // MARK: - Effect Properties
    @Published var reverbEnabled: Bool = false
    @Published var delayEnabled: Bool = false
    @Published var reverbWetness: Float = 0.5
    @Published var delayTime: TimeInterval = 0.3
    
    // MARK: - Waveform Properties
    @Published var waveformData: [Float] = []
    @Published var playbackWaveformData: [Float] = []
    private let waveformSampleCount = 50
    
    
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
        mixer = AVAudioMixerNode()
        reverbNode = AVAudioUnitReverb()
        delayNode = AVAudioUnitDelay()
        
        // Audio session setup
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            // 入力ノードのフォーマットを取得
            let inputNode = audioEngine.inputNode
            _ = inputNode.inputFormat(forBus: 0)
            
            // 録音フォーマットを設定（44.1kHz, 16bit, mono）
            format = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: 44100,
                channels: 1,
                interleaved: false
            )
            
            setupRealTimeAudioProcessing()
            
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
    
    // MARK: - Real-time Audio Processing Setup
    private func setupRealTimeAudioProcessing() {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // エフェクトノードをエンジンにアタッチ
        audioEngine.attach(reverbNode)
        audioEngine.attach(delayNode)
        audioEngine.attach(mixer)
        
        // エフェクト設定
        reverbNode.loadFactoryPreset(.mediumHall)
        reverbNode.wetDryMix = 0 // 初期は無効
        
        delayNode.delayTime = 0.3
        delayNode.feedback = 25
        delayNode.wetDryMix = 0 // 初期は無効
        
        // オーディオグラフ接続
        audioEngine.connect(inputNode, to: delayNode, format: inputFormat)
        audioEngine.connect(delayNode, to: reverbNode, format: inputFormat)
        audioEngine.connect(reverbNode, to: mixer, format: inputFormat)
        audioEngine.connect(mixer, to: audioEngine.outputNode, format: inputFormat)
        
        // ボリュームモニタリング用のタップを設定
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            DispatchQueue.main.async {
                self?.updateVolumeLevel(from: buffer)
                self?.updateWaveformData(from: buffer)
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
            
            // AVAudioRecorderの設定
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            // リアルタイム処理開始
            if !audioEngine.isRunning {
                audioEngine.prepare()
                try audioEngine.start()
            }
            
            // 録音開始
            audioRecorder?.record()
            
            DispatchQueue.main.async {
                self.isRecording = true
                self.descript = "録音中..."
                // 波形データをリセット
                self.waveformData = Array(repeating: 0.0, count: self.waveformSampleCount)
            }
            
        } catch {
            print("Recording start error: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        // 録音停止
        audioRecorder?.stop()
        
        // リアルタイム処理は継続（ユーザーがエフェクトを聞き続けられるように）
        
        // Save to SwiftData
        saveAudioToSwiftData()
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.descript = "録音完了"
            // 録音データを再生用にコピー
            self.playbackWaveformData = self.waveformData
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
    
    private func updateWaveformData(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frames = buffer.frameLength
        let samplesPerSegment = Int(frames) / waveformSampleCount
        var newWaveformData: [Float] = []
        
        for i in 0..<waveformSampleCount {
            let startIndex = i * samplesPerSegment
            let endIndex = min(startIndex + samplesPerSegment, Int(frames))
            
            var segmentSum: Float = 0.0
            for j in startIndex..<endIndex {
                segmentSum += abs(channelData[j])
            }
            
            let segmentAverage = segmentSum / Float(endIndex - startIndex)
            newWaveformData.append(segmentAverage)
        }
        
        // 録音中は最新データを蓄積
        if isRecording {
            waveformData = newWaveformData
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
            // 録音ファイルの長さを取得
            let audioURL = URL(fileURLWithPath: path)
            let asset = AVURLAsset(url: audioURL)
            let durationCMTime = try await asset.load(.duration)
            let duration = CMTimeGetSeconds(durationCMTime)
            
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
    
    // MARK: - Effect Control Methods
    func toggleReverb() {
        reverbEnabled.toggle()
        reverbNode.wetDryMix = reverbEnabled ? reverbWetness * 100 : 0
    }
    
    func toggleDelay() {
        delayEnabled.toggle()
        delayNode.wetDryMix = delayEnabled ? 50 : 0
    }
    
    func setReverbWetness(_ value: Float) {
        reverbWetness = value
        if reverbEnabled {
            reverbNode.wetDryMix = value * 100
        }
    }
    
    func setDelayTime(_ value: TimeInterval) {
        delayTime = value
        delayNode.delayTime = value
    }
    
    func stopRealTimeProcessing() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
    
    func startRealTimeProcessing() {
        if !audioEngine.isRunning {
            do {
                audioEngine.prepare()
                try audioEngine.start()
            } catch {
                print("Failed to start real-time processing: \(error)")
            }
        }
    }
    
    deinit {
        playbackTimer?.invalidate()
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
}
