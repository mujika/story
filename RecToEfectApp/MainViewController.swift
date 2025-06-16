//
//  RecordViewController.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/02/13.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//
///録音終了時にaudioFileにオーディオデータを入れてみる!!

import UIKit
import AVFoundation
import AudioToolbox
import RealmSwift
import CoreMotion
import Accelerate
import CoreAudioKit

let cw:Int = 70





class MainViewController: UIViewController {
    
    // テストゾーン
    public typealias ViewController = UIViewController
    func requestViewControllerWithCompletionHandler(_ completionHandler: @escaping (UIViewController?) -> Void) {
        guard let avAudioUnit = self.activeAVAudioUnit else {
            print("ありますか　ラー")
            return
        }
        
        let audioUnit = avAudioUnit.auAudioUnit
        audioUnit.requestViewController { viewController in
            completionHandler(viewController)
        }
    }
    
    
   // @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var backGroundImageView: BackgroundImageView!
    
    //AudioUnit host test
    var components = [AVAudioUnitComponent]()
    fileprivate var effect: AVAudioUnit!

    
    let imageView  = UIImageView(frame: CGRect(x: (92 - cw) / 2, y: (92 - cw) / 2, width: cw, height: cw))
    let startButton = UIImageView(frame: CGRect(x: 15, y: 26, width: 27, height: 27))
    
    var textView: UITextView!
    var isText = true
    var seekCheck = true
    
    //録音監視用
    var kanshi = 0
    
    //var fru:[String] = []
    ///
    var audioEngine: AVAudioEngine!  //オーディオ信号を生成して処理、オーディオの入出力を行うために使用、接続されたオーディオノードオブジェクトのグループ
    var audioEngineMix : AVAudioEngine!
    var audioFile: AVAudioFile!  //読み書き用に開くことができるオーディオファイル
    var audioFilePlayer: AVAudioPlayerNode!//再生をスケジューリングすることができます。
    var outref: ExtAudioFileRef? //拡張オーディオファイルオブジェクトを表す不透明な構造体。
    var mixer: AVAudioMixerNode!
    // 録音フォーマット（44.1K PCM 16Bit インターリーブ）を設定
    var format: AVAudioFormat!
    let sampleRate = 44100.0
    // set the buffer duration to 5 ms
    let bufferDuration: TimeInterval = 0.004
    
    var offset:Double = 0.0
    var duration:Double = 0.0 //音源の総再生時間
    var currentTime:Double!
    
    var filePath: String? = nil
    var waveFormPath : String? = nil
    var isPlay = false
    var isRec = false
    var isJudgement = false
    
    ///Realm関連
    let realm = try! Realm()
    var config = Realm.Configuration()
    private var audioList: Results<AudioSave>!
    private var audioListNumber = 0
    private var waveformList: Results<WaveformSave>!

    var touchBool = true // クルクルUIのtouchesMove検出用
    
    //UI
    var playButton: PlayButton!
    var waveFormView: DrawWaveform!
    var kurukuruView: KurukuruUI!
    var volumeSet = 0.0
    //Recアニメーション部品
    var recCenterInView:UIView!
    var recView: RecordButton!
    var selectView: CustouTableView!
    
    //日時取得系
    let dateGet = DateFormatter()
    var timer: Timer!
    
    var audioFileUrl:URL?
    var newAudioFileUrl: String?
    
    //エフェクトテスト
    var activeAVAudioUnit:AVAudioUnit?
    var observer: NSKeyValueObservation?
    enum UserPresetsChangeType: Int {
        case save
        case delete
        case external
        case undefined
    }
    public struct Preset {
        init(name: String) {
            let preset = AUAudioUnitPreset()
            preset.name = name
            preset.number = -1
            self.init(preset: preset)
        }
        fileprivate init(preset: AUAudioUnitPreset) {
            audioUnitPreset = preset
        }
        fileprivate let audioUnitPreset: AUAudioUnitPreset
        public var number: Int { return audioUnitPreset.number }
        public var name: String { return audioUnitPreset.name }
    }
    struct UserPresetsChange {
        let type: UserPresetsChangeType
        let userPresets: [Preset]
    }
    public var userPresets: [Preset] {
        guard let presets = auauEfect?.userPresets else { return [] }
        return presets.map { Preset(preset: $0) }.reversed()
    }
    var userPresetChangeType: UserPresetsChangeType = .undefined
    
    private var auauEfect: AUAudioUnit? {
        didSet {
            // A new audio unit was selected. Reset our internal state.
            observer = nil
            userPresetChangeType = .undefined

            // If the selected audio unit doesn't support user presets, return.
            guard auauEfect?.supportsUserPresets ?? false else { return }
            
            // Start observing the selected audio unit's "userPresets" property.
            observer = auauEfect?.observe(\.userPresets) { _, _ in
                DispatchQueue.main.async {
                    var changeType = self.userPresetChangeType
                    // If the change wasn't triggered by a user save or delete, it changed
                    // due to an external add or remove from the presets folder.
                    if ![.save, .delete].contains(changeType) {
                        changeType = .external
                    }
                    
                    // Post a notification to any registered listeners.
                    let change = UserPresetsChange(type: changeType, userPresets: self.userPresets)
                    NotificationCenter.default.post(name: .userPresetsChanged, object: change)
                    
                    // Reset property to its default value
                    self.userPresetChangeType = .undefined
                }
            }
        }
    }
    var EqGain: AVAudioUnitEQ!
    var delay : AVAudioUnitDelay!
    
    var picker: UIImagePickerController!
    var imageButton: UIButton!
    var timeLabel: UILabel!
    var seekLabel: UILabel!
    //var backgroundImage:UIImage!
    let imageSave = ImageSave()
    
    var swipeJudge = true
    let motionManager = CMMotionManager()//加速度センサー
    //設定View
    var container: UIView!
    var leftSwipeCopy:UIPanGestureRecognizer!
    //containerのwidth
    let screanWidth : Int = Int(UIScreen.main.bounds.width/4*3)
    var plivacypolicyButton: UIButton!
    
    var convertToPointsCheck = true
    
    var waveFormArray : [Double] = [] //waveFormの配列保存用
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
    }
    
   
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.next?.touchesBegan(touches, with: event)
        
    }
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    public var instantiationOptions: AudioComponentInstantiationOptions = .loadOutOfProcess
    //audioComponentDescription
    //テステス
    
    
        
    func loadAudioUnits() {
            let componentType = kAudioUnitType_Effect
        
             // Make a component description matching any Audio Unit of the selected component type.
            let description = AudioComponentDescription(componentType: componentType,
                                                        componentSubType: 0,
                                                        componentManufacturer: 0,
                                                        componentFlags: 0,
                                                        componentFlagsMask: 0)

            self.components = AVAudioUnitComponentManager.shared().components(matching: description)
        let componentDescription = self.components[5].audioComponentDescription
            AVAudioUnit.instantiate(with: componentDescription, options: instantiationOptions) { avAudioUnit, error in
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        print("つうかー")
                    }

                    return
                }
            
                self.auauEfect = avAudioUnit?.auAudioUnit
                self.activeAVAudioUnit = avAudioUnit
                
            }
            
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAudioUnits()
        print("ありますか？\(components)")
        
        for n in 0..<self.components.count {
            print("ありますか\(n)？\(components[n].name)")
            print("ありますか\(n)？\(components[n].manufacturerName)")
            //print("ありますか\(n)？\(components[n].audioComponentDescription)")
            
            
            
        }
    
        /*
        func selectAudioUnit(at index: Int) {
            let description = components[index].audioComponentDescription
            
            // Instantiate using AVFoundation's AVAudioUnit class method.
            AVAudioUnit.instantiate(with: description, options: []) { avAudioUnit, error in
                guard error == nil else {
                    DispatchQueue.main.async { /* Show error message to user. */ }
                    return
                }
                
                // Audio unit successfully instantiated.
                // Connect it to AVAudioEngine to use.
            }
        }
        
        */
        
        
        
        initDisplaysizeFit()
        
        backGroundImageView.isUserInteractionEnabled = true
        //AppDelegateからMainViewControllerの関数（変数もいけるっぽい）処理
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mainViewController = self
        //pcmFormatFloat32
        format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                               sampleRate: sampleRate,
                               channels: 1,
                               interleaved: true)
        ///realmを取り込みAudioEngineに渡す？
        audioList = realm.objects(AudioSave.self)
        waveformList = realm.objects(WaveformSave.self)
        
        dateGet.timeStyle = .none
        dateGet.dateStyle = .medium
        //dateGet.locale = Locale(identifier: "ja_JP")
        
        
        startAccelerometer()
        loadImage()
        initSelectView()
        initKurukuru()
        initRecButton()
        initPlayButyton()
        initImagePicker()
        initWaveFormView()
        initTimelabel()
        initContainerView()
        initPlapoliButton()
        
        audioEngine = AVAudioEngine()
        audioFilePlayer = AVAudioPlayerNode()
        mixer = AVAudioMixerNode()
        EqGain = AVAudioUnitEQ()
        delay = AVAudioUnitDelay()
        audioEngine.attach(audioFilePlayer)
        audioEngine.attach(mixer)
        audioEngine.attach(EqGain)
        audioEngine.attach(delay)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {(granted:Bool) in })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:-
//MARK:パーツ設置系
extension MainViewController {
    
    func initDisplaysizeFit() {
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max R
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            print(" iPhoneXS 12 Display")
        
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhoneSE
            print("iPhone5, SE Display")
            
        case iPhone12Pro.screenSize://iPhoneSE
            print("iPhone12Pro Display")
            
        case iPhone12ProMax.screenSize://iPhoneSE
            print("iPhone12ProMax Display")
            
        ////////////////////////////iPad
            
            
        case iPad7_9.screenSize:
            print("iPad7_9")
            
        case iPad10_2.screenSize:
            print("iPad10_2")
            
        case iPad10_5.screenSize:
            print("iPad10_5")
            
        case iPad11_0.screenSize:
            print("iPad11_0")
            
        case iPad12_9.screenSize:
            print("iPad12_9")
            
        default:
            print("NoHit")
        }
    }
    
    
    func initSelectView() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max R
            selectView = iPhoneXSMaxR.selectView
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            selectView = iPhoneXS.selectView
            print(" iPhoneXS Display")
            
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            selectView = iPhone678Plus.selectView
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            selectView = iPhone678.selectView
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            selectView = iPhoneSE.selectView
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            selectView = iPad7_9.selectView
            print("iPad7_9")
            
        case iPad10_2.screenSize:
            selectView = iPad10_2.selectView
            print("iPad10_2")
            
        case iPad10_5.screenSize:
            selectView = iPad10_5.selectView
            print("iPad10_5")
           
        case iPad11_0.screenSize:
            selectView = iPad11_0.selectView
            print("iPad11_0")
            
        case iPad12_9.screenSize:
            selectView = iPad12_9.selectView
            print("iPad12_9")
            
        case iPhone12Pro.screenSize:
            selectView = iPhone12Pro.selectView
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            selectView = iPhone12ProMax.selectView
            print("iPhone12ProMax")
            
       
        default:
            print("NoHit")
        }
        
        selectView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.55)
        
        selectView.dataSource = self
        selectView.delegate = self
        selectView.rowHeight = 85
        selectView.isUserInteractionEnabled = true
        

        self.view.addSubview(selectView)
    }
 
    func initWaveFormView() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
            waveFormView = iPhoneXSMaxR.waveFormView
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            waveFormView = iPhoneXS.waveFormView
            print(" iPhoneXS Display")
        
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            waveFormView = iPhone678Plus.waveFormView
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            waveFormView = iPhone678.waveFormView
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            waveFormView = iPhoneSE.waveFormView
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            waveFormView = iPad7_9.waveFormView
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            waveFormView = iPad10_2.waveFormView
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            waveFormView = iPad10_5.waveFormView
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            waveFormView = iPad11_0.waveFormView
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            waveFormView = iPad12_9.waveFormView
            print("iPad12_9")
            
        case iPhone12Pro.screenSize:
            waveFormView = iPhone12Pro.waveFormView
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            waveFormView = iPhone12ProMax.waveFormView
            print("iPhone12ProMax")
            
        default:
            print("NoHit")
        }
        
        
        waveFormView.backgroundColor = UIColor.clear
        view.addSubview(waveFormView)
    }
    
    func initKurukuru() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
            kurukuruView = iPhoneXSMaxR.kurukuruView
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            kurukuruView = iPhoneXS.kurukuruView
            print(" iPhoneXS Display")
            
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            kurukuruView = iPhone678Plus.kurukuruView
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            kurukuruView = iPhone678.kurukuruView
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            kurukuruView = iPhoneSE.kurukuruView
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            kurukuruView = iPad7_9.kurukuruView
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            kurukuruView = iPad10_2.kurukuruView
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            kurukuruView = iPad10_5.kurukuruView
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            kurukuruView = iPad11_0.kurukuruView
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            kurukuruView = iPad12_9.kurukuruView
            print("iPad12_9")
            
        case iPhone12Pro.screenSize:
            kurukuruView = iPhone12Pro.kurukuruView
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            kurukuruView = iPhone12ProMax.kurukuruView
            print("iPhone12ProMax")
            
        default:
            print("NoHit")
        }
        
        
        kurukuruView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        kurukuruView.layer.cornerRadius = 46
        kurukuruView.clipsToBounds = true //layer.cornerRadiusのコーナーを丸める許可
        kurukuruView.delegate = self
        //kurukuruView.delegateGesture = PageViewController()
        kurukuruView.isUserInteractionEnabled = true
        view.addSubview(kurukuruView)
        
        let image1:UIImage = #imageLiteral(resourceName: "Kurukuru")
        
        imageView.image = image1
        kurukuruView.addSubview(imageView)
    }
    
    
    func initPlayButyton() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
            playButton = iPhoneXSMaxR.playButton
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            playButton = iPhoneXS.playButton
            print(" iPhoneXS Display")
          
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            playButton = iPhone678Plus.playButton
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            playButton = iPhone678.playButton
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            playButton = iPhoneSE.playButton
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            playButton = iPad7_9.playButton
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            playButton = iPad10_2.playButton
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            playButton = iPad10_5.playButton
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            playButton = iPad11_0.playButton
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            playButton = iPad12_9.playButton
            print("iPad12_9")
            
        case iPhone12Pro.screenSize:
            playButton = iPhone12Pro.playButton
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            playButton = iPhone12ProMax.playButton
            print("iPhone12ProMax")
            
        default:
            print("NoHit")
        }
        
        
        playButton.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        playButton.layer.cornerRadius = 40
        playButton.clipsToBounds = true
        playButton.delegate = self
        playButton.isUserInteractionEnabled = true
        print("UIScreen.main.bounds.size\(UIScreen.main.bounds.size)")
        
        startButton.image = UIImage(named: "StartButton")
        print("画面サイズ\(self.view.frame.size)")

        
        playButton.addSubview(startButton)
        view.addSubview(playButton)
    }
    
    //recButton設置
    func initRecButton() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max R
            recView = iPhoneXSMaxR.recView
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            //レコードボタン外から１層め
            recView = iPhoneXS.recView
            print(" iPhoneXS Display")
          
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            recView = iPhone678Plus.recView
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            recView = iPhone678.recView
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhoneSE
            //レコードボタン外から１層め
            recView = iPhoneSE.recView
            print("iPhoneSE Display")
            
            
        case iPad7_9.screenSize:
            recView = iPad7_9.recView
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            recView = iPad10_2.recView
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            recView = iPad10_5.recView
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            recView = iPad11_0.recView
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            recView = iPad12_9.recView
            print("iPad12_9")
            
        case iPhone12Pro.screenSize:
            recView = iPhone12Pro.recView
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            recView = iPhone12ProMax.recView
            print("iPhone12ProMax")
            
        default:
            print("NoHit")
        }
        
        
        recView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        recView.layer.cornerRadius = 40
        recView.clipsToBounds = true// 右上の角と左上の角を丸くする
        recView.delegate = self
        recView.isUserInteractionEnabled = true
   
        //レコードボタン（アニメーション部分）
        self.recCenterInView = UIView(frame: CGRect(x: 11, y: 11, width: 58, height:58))
        self.recCenterInView.backgroundColor = UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.8)
        self.recCenterInView.layer.cornerRadius = 29
       
    
        self.view.addSubview(recView)
        recView.addSubview(self.recCenterInView)

    }

    private func initTextView() {
        
        textView = UITextView()
        textView.backgroundColor = UIColor(red: 0.0159801, green: 0.0297349, blue:0.151864, alpha: 1.0)
        textView.becomeFirstResponder()
        textView.text = "NoTitle"
        textView.textColor = UIColor.lightGray
        textView.keyboardAppearance = .dark  //キーボードをダークモード化
        //self.textView.frame = CGRect(x: self.view.frame.width / 2 - 100, y: self.view.frame.height / 2 - 15, width: 200, height: 30)
        textView.delegate = self
        //textViewの位置とサイズを設定
        textView.frame = CGRect(x:0, y:130, width:self.view.frame.width, height:349)
    
        //フォントの大きさを設定
        textView.font = UIFont.systemFont(ofSize: 18.0)
        
        //textViewの枠線の太さを設定
        //textView.layer.borderWidth = 0.5
        
        //枠線の色をグレーに設定
        //textView.layer.borderColor = UIColor.lightGray.cgColor
        
        //テキストを編集できるように設定
        textView.isEditable = true
        
        //Viewに追加
        self.view.addSubview(textView)
        
    }
    
    func initImagePicker() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
            imageButton = iPhoneXSMaxR.imageButton
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            imageButton = iPhoneXS.imageButton
            print(" iPhoneXS Display")
           
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            imageButton = iPhone678Plus.imageButton
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            imageButton = iPhone678.imageButton
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            imageButton = iPhoneSE.imageButton
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            imageButton = iPad7_9.imageButton
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            imageButton = iPad10_2.imageButton
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            imageButton = iPad10_5.imageButton
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            imageButton = iPad11_0.imageButton
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            imageButton = iPad12_9.imageButton
            print("iPad12_9")
            
        case iPhone12Pro.screenSize:
            imageButton = iPhone12Pro.imageButton
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            imageButton = iPhone12ProMax.imageButton
            print("iPhone12ProMax")
        default:
            print("NoHit")
        }
        
        imageButton.addTarget(self, action: #selector(startPick), for: UIControl.Event.touchUpInside)
        imageButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //button.titleLabel?.textColor = UIColor.black
        imageButton.setTitleColor(UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7), for: UIControl.State.normal)
        imageButton.titleLabel?.numberOfLines = 0
        imageButton.titleLabel?.textAlignment = .center
        imageButton.setTitle("Background\nImage", for: UIControl.State.normal)
        imageButton.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        
        imageButton.layer.cornerRadius = 8
        
        imageButton.layer.borderColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).cgColor
        imageButton.layer.borderWidth = 1
        imageButton.isUserInteractionEnabled = true
        view.addSubview(imageButton)
    }
    
    func initTimelabel() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
            seekLabel = iPhoneXSMaxR.seekLabel
            timeLabel = iPhoneXSMaxR.timeLabel
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            seekLabel = iPhoneXS.seekLabel
            timeLabel = iPhoneXS.timeLabel
            print(" iPhoneXS Display")
            
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            seekLabel = iPhone678Plus.seekLabel
            timeLabel = iPhone678Plus.timeLabel
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            seekLabel = iPhone678.seekLabel
            timeLabel = iPhone678.timeLabel
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            seekLabel = iPhoneSE.seekLabel
            timeLabel = iPhoneSE.timeLabel
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            seekLabel = iPad7_9.seekLabel
            timeLabel = iPad7_9.timeLabel
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            seekLabel = iPad10_2.seekLabel
            timeLabel = iPad10_2.timeLabel
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            seekLabel = iPad10_5.seekLabel
            timeLabel = iPad10_5.timeLabel
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            seekLabel = iPad11_0.seekLabel
            timeLabel = iPad11_0.timeLabel
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            seekLabel = iPad12_9.seekLabel
            timeLabel = iPad12_9.timeLabel
        print("iPad12_9")
            
      
            
        case iPhone12Pro.screenSize:
            seekLabel = iPhone12Pro.seekLabel
            timeLabel = iPhone12Pro.timeLabel
            print("iPhone12Pro")
            
        case iPhone12ProMax.screenSize:
            seekLabel = iPhone12Pro.seekLabel
            timeLabel = iPhone12Pro.timeLabel
            print("iPhone12ProMax")
            
        default:
            print("NoHit")
        }
        
        seekLabel.layer.cornerRadius = 3
        seekLabel.clipsToBounds = true
        timeLabel.layer.cornerRadius = 4
        timeLabel.clipsToBounds = true
        timeLabel.textAlignment = NSTextAlignment.right
        
        seekLabel.textColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7)
        timeLabel.textColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7)
        
        seekLabel.backgroundColor = .clear
        timeLabel.backgroundColor = .clear
        waveFormView.addSubview(seekLabel)
        waveFormView.addSubview(timeLabel)
    }
    
    func initContainerView(){
        
        let containerHeight : Int = Int(UIScreen.main.bounds.height)
        container = UIView(frame: CGRect(x:-(screanWidth), y: 0, width: screanWidth, height: containerHeight))
        container.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.95)
        
        
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.edgeView(sender:)))   //Swift3
        
        edgeGesture.edges = .left  //左端をスワイプするのを検知する
        
        // viewにエッジを登録
        self.view.addGestureRecognizer(edgeGesture)
        
        self.view.addSubview(container)
    }
    
    func initPlapoliButton() {
        self.plivacypolicyButton = UIButton(frame: CGRect(x: 0, y: 100, width: screanWidth/5*3, height: 50))
        //self.plivacypolicyButton.backgroundColor = UIColor.black
        
        let attrs0 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19.0),  NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.underlineStyle : 0] as [NSAttributedString.Key : Any]
        /*
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19.0),  NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]*/
        let attributedString = NSMutableAttributedString(string:"○ ", attributes: attrs0)
        let buttonTitleStr = NSMutableAttributedString(string:"Plivacy policy", attributes: attrs0)
        attributedString.append(buttonTitleStr)
        self.plivacypolicyButton.setAttributedTitle(attributedString, for: .normal)
        self.plivacypolicyButton.setTitleColor(.white, for: .normal)
        self.plivacypolicyButton.addTarget(self, action: #selector(pushButton(_:)), for: .touchUpInside)
        self.plivacypolicyButton.isUserInteractionEnabled = true
        self.container.addSubview(self.plivacypolicyButton)
    }
}



//MARK:-
//MARK: ボタン動作系
extension MainViewController {
    
    @objc func pushButton(_ sender: UIButton){
        //外部ブラウザでURLを開く
        let url = NSURL(string: "https://scrapbox.io/Pickout/Privacy_policy")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        print("プラポリ")
    }
    
    @objc func swipeView(sender: UIPanGestureRecognizer) {
        print("swipe")
        
        //移動量を取得する。
        let move:CGPoint = sender.translation(in: view)
        //let containerWidth  : Int = Int(UIScreen.main.bounds.width)
        let containerHeight : Int = Int(UIScreen.main.bounds.height)
        
        //位置の制約に垂h水平方向の移動量を加算する。
        var nextValue = Int(container.frame.minX + move.x)
        if nextValue > 0 {
            nextValue = 0
        }
        
        container.frame = CGRect(
            x : Int(nextValue),
            y : 0,
            width  : screanWidth,
            height : containerHeight)
        //画面表示を更新する。
        self.view.layoutIfNeeded()
        
        //ドラッグ終了時の処理
               if(sender.state == UIGestureRecognizer.State.ended) {
                       if(container.frame.minX + CGFloat(screanWidth) < view.frame.size.width/2) {
                           //ドラッグの距離が画面高さの半分に満たない場合はビュー画面外に戻す。
                           container.frame = CGRect(
                               
                            
                            x : screanWidth * -1,
                            y : 0,
                            width  : screanWidth,
                            height : containerHeight)
                        print("反応しています")
                        
                        //let leftSwipe = UIPanGestureRecognizer(target: self, action: #selector(self.swipeView(sender:)))   //Swift3
                        //self.leftSwipeCopy
                           // leftSwipeジェスチャーを削除
                        self.view.removeGestureRecognizer(self.leftSwipeCopy)
                
                           
                       } else {
                           //ドラッグの距離が画面高さの半分以上の場合はそのままビューを下げる。
                           container.frame = CGRect(
                           x : 0,
                           y : 0,
                           width  : screanWidth,
                           height : containerHeight)
                       }
                       //アニメーションさせる。
                   UIView.animate(withDuration: 0.8,animations: { self.view.layoutIfNeeded()},completion:nil)
               }
               // リセット
                      sender.setTranslation(
                          CGPoint(x : 0, y : 0),
                          in : view)
        
        
    }
    
    @objc func edgeView(sender: UIScreenEdgePanGestureRecognizer) {
        print("edge")
        
        //移動量を取得する。
        let move:CGPoint = sender.translation(in: view)
        //let containerWidth: Int = Int(UIScreen.main.bounds.width)
        let containerHeight: Int = Int(UIScreen.main.bounds.height)
        
        //位置の制約に垂h水平方向の移動量を加算する。
        var nextValue = Int(container.frame.minX + move.x)
        if nextValue > 0 {
            nextValue = 0
        }
       
        
        container.frame = CGRect(
            x : Int(nextValue),
            y : 0,
            width  : screanWidth,
            height : containerHeight)
        //画面表示を更新する。
        self.view.layoutIfNeeded()
        
       
        
       //ドラッグ終了時の処理
        if(sender.state == UIGestureRecognizer.State.ended) {
                if(container.frame.minX + CGFloat(screanWidth) < view.frame.size.width/2) {
                    //ドラッグの距離が画面高さの半分に満たない場合はビュー画面外に戻す。
                    container.frame = CGRect(
                        x : screanWidth * -1,
                    y : 0,
                    width  : screanWidth,
                    height : containerHeight)
                    
                } else {
                    //ドラッグの距離が画面高さの半分以上の場合はそのままビューを下げる。
                    container.frame = CGRect(
                    x : 0,
                    y : 0,
                    width  : screanWidth,
                    height : containerHeight)
                    
                    let leftSwipe = UIPanGestureRecognizer(target: self, action: #selector(self.swipeView(sender:)))   //Swift3
                    self.leftSwipeCopy = leftSwipe
                    // viewにleftSwipeを登録
                    self.view.addGestureRecognizer(leftSwipe)
                }
                //アニメーションさせる。
            UIView.animate(withDuration: 0.8,animations: { self.view.layoutIfNeeded()},completion:nil)
        }
        // リセット
               sender.setTranslation(
                   CGPoint(x : 0, y : 0),
                   in : view)
            
        
        // 移動予定の値
            
/*
            // 制限
            let upLimit = screenWidth - containerWidth
            if upLimit > nextValue { nextValue = upLimit }

            let underLimit = screenWidth
            if underLimit < nextValue { nextValue = underLimit }
*/
           

            
        }

    
    func loadImage() {
        if realm.objects(ImageSave.self).count == 1 {
            let imageSaveLoad = realm.objects(ImageSave.self).first!
            backGroundImageView.image = UIImage(data: imageSaveLoad.imageData)
        } else {
            backGroundImageView.image = UIImage(named: "flower")
            
        }
    }
    
    
    func startRecord() {
        self.isRec = true
        if timer != nil {
            timer.invalidate()
        }
        
        //let auoi:AVAudioUnit
        /*
        let auComponent: AVAudioUnitComponent?
        auComponent = components[15]
        let componentDescription: AudioComponentDescription?
        componentDescription = auComponent?.audioComponentDescription
        print("通貨地点1\(String(describing: auComponent?.audioComponentDescription))")
        if let componentDescription = componentDescription {
            AVAudioUnit.instantiate(with: componentDescription, options: []) { avAudioUnit, error in
                print("通貨地点2")
                guard let avAudioUnitEffect = avAudioUnit else {
                    print("通貨地点3")
                    return }
                
                self.effect = avAudioUnitEffect
                self.audioEngine.attach(avAudioUnitEffect)
                print("通貨地点4")
                
                // Disconnect player -> mixer.
                //self.engine.disconnectNodeInput(self.engine.mainMixerNode)
                
              
                
                
            }
        }
        */
        
        
        
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
        try! AVAudioSession.sharedInstance().setPreferredIOBufferDuration(bufferDuration)
        try! AVAudioSession.sharedInstance().setActive(true)
       // let currentRoute = AVAudioSession.sharedInstance().currentRoute
        //self.descript.text = String(describing: currentRoute.inputs.last!.portName) + " と　" + String(describing: convertFromAVAudioSessionPort(currentRoute.inputs.last!.portType))
        //てすと
        
        
        //audioEngine.attach(audioFilePlayer)
        //audioEngine.attach(mixer)
        //audioEngine.attach(EqGain)
        volumeSet = 0.0
        EqGain.globalGain = Float(volumeSet)
        //delay.delayTime = 1
        //delay.wetDryMix = 45

        /*
         私たちのアプリでは、iOSでかなりの頻度でこれを見ています。iPhone 6 から 11 (および一部の iPad) まで、あらゆる種類のデバイスで発生しています。通常、inputNode.inputFormatのサンプルレートがoutputNode.outputFormatのサンプルレートと一致しない場合に発生します。

         これは、Facetime 通話中であれば再現可能であることに気付きましたが、通話検知機能を追加したため、一部のユーザーではまだ発生しています。

         以下は、必須条件が false でアプリがクラッシュする直前のログからのサンプルです: format.sampleRate == hwFormat.sampleRate.
         */
        
        //audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: format)
        //audioEngine.attach(audioEffectE)
        let formatZ = audioEngine.inputNode.inputFormat(forBus: 0)
        
        guard let avAudioUnit = self.activeAVAudioUnit else {
            print("ありますか　ラー")
            return
        }
        
        
//        self.audioEngine.attach(avAudioUnit)
        // Get the underlying AudioUnit instance.
       


            // Disconnect player -> mixer.
        self.audioEngine.disconnectNodeInput(self.audioEngine.mainMixerNode)
        

        //let jjlnlnl = auauEfect.inputFormat(forBus: 0)
        //一旦置いとく
        //formatZ
       // let hardwareFormat = self.audioEngine.outputNode.outputFormat(forBus: 0)
        let stereoFormat = AVAudioFormat(standardFormatWithSampleRate: formatZ.sampleRate, channels: 2)
            // Connect player -> effect -> mixer.
        self.audioEngine.connect(audioEngine.inputNode, to: self.mixer, format: formatZ)
        self.audioEngine.connect(self.mixer, to: self.audioEngine.mainMixerNode, format: stereoFormat)
//        self.audioEngine.connect(self.mixer, to: avAudioUnit, format: stereoFormat)
//        self.audioEngine.connect(avAudioUnit, to: self.audioEngine.mainMixerNode, format: stereoFormat)
        print("ありますかねname？\(avAudioUnit.name)")
        print("ありますかね？auAuduiUnitInputBusses\(avAudioUnit.auAudioUnit.inputBusses)")
        print("ありますかね？auAuduiUnitOutputBusses\(avAudioUnit.auAudioUnit.outputBusses)")
        
        /*エフェクト表示
        requestViewControllerWithCompletionHandler { [weak self] viewController in
            guard let strongSelf = self else { return }
            guard let viewController = viewController, let view = viewController.view else { return }

            strongSelf.addChild(viewController)
            let parentRect = strongSelf.view.bounds
            view.frame = CGRect(
                x: 0,
                y: parentRect.size.height / 5,
                width: parentRect.size.width,
                height: parentRect.size.height * 2 / 5)

            strongSelf.view.addSubview(view)
            viewController.didMove(toParent: self)
            print("ありますかね？しょわっち")
            //strongSelf.viewBtn.title = "CloseAUVC"
        }　*/

        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: formatZ)
 
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        filePath = dir.appending("/temp.wav")
        print("クラッシュA")
        //waveFormPath = dir.appending("/temp.waveform")
        
        // 書込みファイル（.wav）を生成（&outref）
        _ = ExtAudioFileCreateWithURL(URL(fileURLWithPath: filePath!) as CFURL,
                                      kAudioFileWAVEType,
                                      formatZ.streamDescription,
                                      nil,
                                      AudioFileFlags.eraseFile.rawValue,
                                      &outref)
        
        // mixerの Tapする（BufferSize毎に Callback(Void in)が呼ばれる）
        self.audioEngine.inputNode.installTap(onBus: 0,
                              bufferSize: AVAudioFrameCount(1024 * 4),
                              format: formatZ,
                              block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                                self.kanshi += 1
                                print("通過!\(self.kanshi)")
                                let audioBuffer: AVAudioBuffer = buffer
                                _ = ExtAudioFileWrite(self.outref!, buffer.frameLength, audioBuffer.audioBufferList)
        })
        print("クラッシュA")
        
        try! self.audioEngine.start()
        kurukuruView.removeFromSuperview()
        playButton.removeFromSuperview()
        selectView.removeFromSuperview()
        imageButton.removeFromSuperview()
        waveFormView.removeFromSuperview()
        seekLabel.removeFromSuperview()
        timeLabel.removeFromSuperview()
        self.plivacypolicyButton.removeFromSuperview()
        container.removeFromSuperview()
        stopAccelerometer()
        print("クラッシュA")
        
    }
    
    func stopRecord() {
        guard isPlay != true else {
            return
        }
        isRec = false
        audioEngine.stop()
        //audioEngine.reset()
        
        self.audioEngine.inputNode.removeTap(onBus: 0)
        ExtAudioFileDispose(self.outref!) //拡張されたオーディオファイルオブジェクトを閉じます。
        outref = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audiosession: (error.localizedDescription)")
        }
        
        
        let data:Data = try! Data(contentsOf: URL(fileURLWithPath: self.filePath!))
        //let waveFormData:Data = try! Data(contentsOf: URL(fileURLWithPath: self.waveFormPath!))
        let audioSaveData = AudioSave()
       
        //audioSaveData.audioData = data
        
        ///ファイル保存実験
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let now = Date()
        let addressget = "effect" + dateFormatter.string(from: now)
        let dateString =  addressget + ".wav"
        let wavearray = addressget + ".array"
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
            
            let path_file_name = dir.appendingPathComponent(dateString).path
            let path_wave_array = dir.appendingPathComponent(wavearray).path
            
            audioSaveData.audiofileAddres = dateString
            audioSaveData.audioTitle = dateString
            //audioSaveData.waveFormL = 0.8
            print("パスねーむ\(String(describing: path_file_name))")
            
            do {
                try data.write(to: URL(fileURLWithPath:path_file_name))
                
            } catch {
                print("できてんのか？")
            }
            self.convertToPointsCheck = true
            //波形生成して保存
            waveConvertToPoints(path_file_name, path_wave_array: path_wave_array, waveformAddress: wavearray)
            let fileURL = URL(fileURLWithPath:path_file_name)
            do {
                audioFile = try AVAudioFile(forReading: fileURL)
                
                kurukuruView.startTime = 0.0
                kurukuruView.value = 0
                self.duration = Double(audioFile.length) / sampleRate
                
                self.offset = 0.0
                waveFormView.startTimepoint = 0
                waveFormView.seekTimepoint = 0
                
                self.seekLabel.text = " 0:00.0"
                self.timeLabel.text = timeMinitsSecond(time: duration)
                
                
                print("データ完了しました!")
            } catch {
                print("きゃっちできてない")
            }
        }
        //痕跡
        //self.isRec = false
        self.currentTime = 0.0
        view.addSubview(waveFormView)
        self.waveFormView.setNeedsDisplay()
        view.addSubview(kurukuruView)
        view.addSubview(playButton)
        view.addSubview(imageButton)
        view.addSubview(selectView)
        view.addSubview(container)
        self.container.addSubview(self.plivacypolicyButton)
        initTimelabel()
        ///realm書き込み
        addAudioItem(audio: audioSaveData)
        
        let result = realm.objects(AudioSave.self)
        self.audioListNumber = result.count - 1
        
        startAccelerometer()
        
    }
    
    
     func startPlay() -> Bool {
        isPlay = true
        guard isRec != true else {
            return true
        }
        if timer != nil {
            timer.invalidate()
        }
        
        audioListRead()
        
        if audioFile.length == 0 {
            print("通過地点")
            timeLabel.text = " 0:00.0"
            seekLabel.text = " 0:00.0"
            return false
        }
        
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)
        
       // EqGain.globalGain = Float(volumeSet)

        audioEngine.connect(audioFilePlayer, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        //audioEngine.connect(EqGain, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
            print("のーえふぇ")
 
        self.audioFilePlayer.scheduleSegment(audioFile,
                                             startingFrame: AVAudioFramePosition(),
                                             frameCount: AVAudioFrameCount(audioFile.length),
                                             at: nil,
                                             completionHandler: nil)
        
        self.waveFormView.setNeedsDisplay()
        audioEngine.prepare()
        
         
        do {
            
            try audioEngine.start()
            
        } catch {
            print("しっぱいそ")
        }
        
        print("し")
        self.audioFilePlayer.play()
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.01,
                                     target: self,
                                     selector: #selector(self.playerTimeGet),
                                     userInfo: nil,
                                     repeats: true)
        
        timeLabel.text = timeMinitsSecond(time: duration)
        seekLabel.text = " 0:00.0"
        stopAccelerometer()
        return true
    }
    
    func stopPlay() {
        isPlay = false
        if self.audioFilePlayer != nil && self.audioFilePlayer.isPlaying {
            self.audioFilePlayer.stop()
        }
        
        if timer != nil {
            timer.invalidate()
        }
        
        self.audioEngine.stop()
        try! AVAudioSession.sharedInstance().setActive(false)
        startAccelerometer()
    }
    
    
    
    func completion() {
        if self.isRec {
            DispatchQueue.main.async {
                //self.rec(UIButton())
            }
        } else if self.isPlay {
            DispatchQueue.main.async {
            }
        }
    }
    
    //オーディオ読み込みメソッド
    func audioListRead() {
        
        
        ///ここをiif文か何かでいけない？
        let objs = self.audioList[audioListNumber]
        let objsWave = self.waveformList[audioListNumber]
        
        
        //let fileURL = URL(fileURLWithPath: objs.audiofileAddres)
        
        var fileString = ""
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
            fileString = dir.appendingPathComponent(objs.audiofileAddres).path
        }
        let fileURL = URL(fileURLWithPath: fileString)
        do {
            audioFile = try AVAudioFile(forReading: fileURL)
        } catch {
            print("きゃっちできてない")
        }
        
        
        var filePathWave = ""
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
            if objsWave.waveFormAddress != "" {
                filePathWave = dir.appendingPathComponent(objsWave.waveFormAddress).path
                waveFormView.convertToPointsCheck = false
                print("ももも")
            } else {
                print("波形データなし")
                waveFormView.convertToPointsCheck = true
            }
            
               }
        // 波形データ読み込み
        guard let waveData = try? Data(contentsOf: URL(fileURLWithPath: filePathWave)) else {
        fatalError("load failed.") }
    
        //DataをCGFloatに変換
        readFile.points = waveData.toArray(type: CGFloat.self)
       print("波形軽々read\(readFile.points)")
        /*
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32,
                                   sampleRate: sampleRate,
                                   channels: 1,
                                   interleaved: false)
        */
        print("audioFile.processingFormat1 \(audioFile.length)")
        print("audioFile.processingFormat2 \(audioFile.processingFormat)")
        print("audioFile.processingFormat3 \(audioFile.fileFormat)")
        let buf = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        print("audioFile.processingFormat4 \(buf!.frameLength)")
        do {
            try audioFile.read(into: buf!)
            
            // this makes a copy, you might not want that
            readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf?.floatChannelData?[0], count:Int(buf!.frameLength)))
            
            print("audioFile.processingFormat6 \(readFile.arrayFloatValues.count)")
            print("realmからオーディオデータ、読み込み成功!")
        } catch {
            print("読み込み失敗")
            return
        }
        duration = Double(audioFile.length) / sampleRate //音声ファイルの総再生時間（秒
        
    }
 
    //とりあえず時間軸操作に入りそうな変数宣言を関数にまとめておく
    
    func audioSeek(_ startTime: Double) {
        var length = duration - startTime // 残り時間取得（sec）
        if length < 0 {
            length = 0
        }
        print("残り時間\(length)")
        
        if audioFile == nil || currentTime == nil {
           // print("ウィングマン\(audioFile)と\(currentTime)")
            return
        }
        print("ウィングマン２")
        if isPlay == false {
            print("ウィングマン３")
            if startPlay() {
                print("ウィングマン4")
                print("start")
            }
        }
        //let nodeTime = audioFilePlayer.lastRenderTime //最後に再生した時間をNodetimeline形式で取得
        //let playerTime = audioFilePlayer.playerTime(forNodeTime: nodeTime!) //Player Timeline形式に変換
        //let currentTime = (Double(playerTime!.sampleTime) / sampleRate) //現在の再生時間を秒で取得
        
        // 前提：
        // ・position にはDouble値で任意の再生位置（秒）が入ってくる前提
        // ・self.duration は総再生時間（秒）
        // ・sampleRateはサンプルレート
        var newsampletime = AVAudioFramePosition(sampleRate * startTime) // シーク位置（AVAudioFramePosition）取得
        
        
        let framestoplay = AVAudioFrameCount(sampleRate * length) // 残りフレーム数（AVAudioFrameCount）取得
        offset = startTime // ←シーク位置までの時間を一旦退避
        
        // 現在の再生時間取得あたりの処理
        //let currentTime = (Double(playerTime!.sampleTime) / sampleRate) + self.offset // ←シーク位置以前の時間を追加
        //指定位置から再生す
        audioFilePlayer.stop()
        
        print("シーク位置\(newsampletime)")
        
        if newsampletime > audioFile.length {
            newsampletime = audioFile.length
            
            print("くるくるバリュー前\(kurukuruView.value)")
            kurukuruView.value = Int(Double(audioFile.length) / sampleRate * 10 )
            print("くるくるバリュー後\(kurukuruView.value)")
        }
        
        if framestoplay > 100 {
            // 指定の位置から再生するようスケジューリング
            audioFilePlayer.scheduleSegment(audioFile,
                                            startingFrame: newsampletime,
                                            frameCount: framestoplay,
                                            at: nil,
                                            completionHandler: nil
            )
        }
        audioFilePlayer.play()
    }
    //playerの時間を取得してwaveViewに反映
    @objc func playerTimeGet() {
        let nodeTime = audioFilePlayer.lastRenderTime //最後に再生した時間をNodetimeline形式で取得
        if nodeTime == nil {return}
        let playerTime = audioFilePlayer.playerTime(forNodeTime: nodeTime!) //Player Timeline形式に変換
        currentTime = (Double(playerTime!.sampleTime) / sampleRate) + self.offset//現在の再生時間を秒で取得
        var seekPoint = Int(currentTime / duration * 147)
        print("シークポイント\(seekPoint)")
        if seekPoint > 147 {
            seekPoint = 147
            self.stopPlay()
            timer.invalidate()
        }
        
        
        waveFormView.startTimepoint = seekPoint
        if seekCheck == true {
            waveFormView.seekTimepoint = seekPoint
        }
        if touchBool == true {
            
            seekLabel.text = timeMinitsSecond(time: floor(currentTime * 10) / 10)
        }
        //timeLabel.text = "\(floor(currentTime * 10) / 10) / \(duration)"
        waveFormView.setNeedsDisplay()
    }
    
    ///realm書き込み（工事中）
    func addAudioItem(audio: AudioSave) {
        print("パペット")
        do {
            try realm.write {
                realm.add(audio)
            }
        } catch {
            print("失敗っす")
        }
        selectView.reloadData()
    }
    
    
    
    
    //Doubleを時計表示もにする
    func timeMinitsSecond(time: Double)  -> String {
        var seekTimeString:String!
        if time < 10 {
            seekTimeString = "0:0" + "".appendingFormat("%.1f", time)
        } else if time < 60 {
            seekTimeString = "0:" + "".appendingFormat("%.1f", time)
        } else {
            
            var count = 0
            var seekMinits = time
            while seekMinits > 60 {
                seekMinits -= 60
                count += 1
            }
            
            if seekMinits < 10 {
                seekTimeString = "\(count):0" + "".appendingFormat("%.1f", seekMinits)
            } else {
                seekTimeString = "\(count):" + "".appendingFormat("%.1f", seekMinits)
            }
            
        }
        
        return seekTimeString
    }
    
    
    func backgroundViewAngle() {
        let angle: CGFloat = CGFloat((180.0 * Double.pi) / 180.0)
        backGroundImageView.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    func outputAccelData(acceleration: CMAcceleration){
        // 加速度センサー [G]
        if acceleration.y > 0.3 {
            let angle: CGFloat = CGFloat((180.0 * Double.pi) / 180.0)
            backGroundImageView.transform = CGAffineTransform(rotationAngle: angle)
            backGroundImageView.setNeedsDisplay()
        } else if acceleration.y < -0.3 {
            let angle: CGFloat = CGFloat((0.0 * Double.pi) / 180.0)
            backGroundImageView.transform = CGAffineTransform(rotationAngle: angle)
            backGroundImageView.setNeedsDisplay()
        }
        
    }
    // センサー値の取得開始
    func startAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
            motionManager.accelerometerUpdateInterval = 1.0
            
            motionManager.startAccelerometerUpdates(
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.outputAccelData(acceleration: accelData!.acceleration)
            })
        }
    }
    
    // センサー取得を止める場合
    func stopAccelerometer(){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    //背景グラデーション
    func colorChange() {
        
        //グラデーションをつける
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.backGroundImageView.bounds
        self.view.backgroundColor = .white
        //グラデーションさせるカラーの設定
        //今回は、徐々に色を濃くしていく
        let color1 = UIColor(red: 177/255.0, green: 23/255.0, blue: 23/255.0, alpha: 0.7).cgColor     //白
        let color2 = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.8).cgColor   //水色
        
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1, color2]
        
        //グラデーションの開始地点・終了地点の設定
        //上が白で下が水色
        //gradientLayer.startPoint = CGPoint.init(x: 0.5, y: 0)
        //gradientLayer.endPoint = CGPoint.init(x: 0.5 , y:1 )
        
        //左が白で右が水色
        //gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        //gradientLayer.endPoint = CGPoint.init(x: 1 , y:0.5)
        
        //左上が白で右下が水色
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1 , y:1)
        
        //ViewControllerのViewレイヤーにグラデーションレイヤーを挿入する
        self.backGroundImageView.layer.insertSublayer(gradientLayer,at:0)
    }
    
   //配列のサイズを減らしてCGFloatに変換
    @objc func convertToPoints() {
            convertToPointsCheck = false
            print("マックス値\(String(describing: readFile.arrayFloatValues.max()))")
            let mapFile = readFile.arrayFloatValues.map{$0}
            print("audioFile.processingFormatmapfile \(mapFile.count)")
            print("audioFile.processingFormatmapfilemax \(String(describing: mapFile.max()))")
            /*ここから"audioFile.processingFormatmapfilemDoun1\(String(describing: downSampledData.max()))"の間に
             audioFile.processingFormatmapfilemax Optional(0.039449207)
             audioFile.processingFormatmapfilemDoun1Optional(0.0)
             になって失われてる( ˘•ω•˘ )
             245行目付近
             */
            
            var processingBuffer = [Float](repeating: 0.0,
                                           count: Int(mapFile.count))
            print("audioFile.processingFormatmapfilemax2 \(String(describing: mapFile.max()))")
            let sampleCount = vDSP_Length(mapFile.count)
            print("audioFile.processingFormatmapfilemax3 \(String(describing: mapFile.max()))")
            
            //vDSP_vabs：配列内のすべての要素の絶対値をとる
            //わるさしてる感ぱねぇ
            // convert do dB
            vDSP_vabs(mapFile, 1, &processingBuffer, 1, sampleCount)
            print("audioFile.processingFormatmapfilemaxp1 \(String(describing: processingBuffer.max()))")
            print("audioFile.processingFormatmapfilemax4 \(String(describing: mapFile.max()))")
            
            var multiplier = 1.0
            if multiplier < 1{
                multiplier = 1.0
            }
            
            //let samplesPerPixel = Int(148 * multiplier) //guiter用￥
            let samplesPerPixel = Int(Double(mapFile.count) / 147.0 * multiplier)
            print("audioFile.processingFormatmapfilesamplesPerPixel \(samplesPerPixel)")
            print("サンプルピクセル\(samplesPerPixel)")
            let filter = [Float](repeating: 1.0 / Float(samplesPerPixel),
                                 count: Int(samplesPerPixel))
            
            var downSampledLength = 147 //Int(readFile.arrayFloatValues.count / samplesPerPixel)
            
            if mapFile.count == 0 {
                downSampledLength = 0
                print("ぜーろー")
            }
            var downSampledData = [Float](repeating:0.0,
                                          count:downSampledLength)
           
           ////////そもそもここでdownSampledDataが上書きされてないかも、、、いってるやん！！！！！！！！！
            vDSP_desamp(processingBuffer,
                        vDSP_Stride(samplesPerPixel),
                        filter,
                        &downSampledData,
                        vDSP_Length(downSampledLength),
                        vDSP_Length(samplesPerPixel))
            print("audioFile.processingFormatmapfilemapFile.count\(downSampledData.count)")
            print("audioFile.processingFormatmapfilemaxd \(String(describing: downSampledData.max()))")
            print("audioFile.processingFormatmapfilemaxp2 \(String(describing: processingBuffer.max()))")
            print("audioFile.processingFormatmapfilemDoun2\(mapFile.count)")
            print("processingBuffer\(processingBuffer.count)")
            print("vDSP_Stride(samplesPerPixel)\(vDSP_Stride(samplesPerPixel))")
            print("vDSP_Length(downSampledLength)\(vDSP_Length(downSampledLength))")
            print("vDSP_Length(samplesPerPixel)\(vDSP_Length(samplesPerPixel))")
     
            //print(vDSP_Stride(samplesPerPixel) * (vDSP_Length(downSampledLength) - 1) + vDSP_Length(samplesPerPixel))
    //        readFileが波形データ？
            readFile.points = downSampledData.map{CGFloat($0)}
            var strin: String = ""
            for n in 0..<147 {
                //ここでエラーが出る
                strin += "、 \(readFile.points[n])"
            }
            print("audioFile.processingFormat7 \(String(describing: readFile.points.max()))")
            
            /*
             ここまで
             */
            print("audioFile.processingFormatmapfilemDoun1\(String(describing: downSampledData.max()))")
        }
    
    
    func waveConvertToPoints(_ path_file_name: String, path_wave_array: String, waveformAddress: String) {
        let fileURL = URL(fileURLWithPath: path_file_name)
        do {
            audioFile = try AVAudioFile(forReading: fileURL)
        } catch {
            print("きゃっちできてない")
        }
        let buf = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        do {
            try audioFile.read(into: buf!)
            
            // this makes a copy, you might not want that
            readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf?.floatChannelData?[0], count:Int(buf!.frameLength)))
            
            print("audioFile.processingFormat6 \(readFile.arrayFloatValues.count)")
            print("realmからオーディオデータ、読み込み成功!")
        } catch {
            print("読み込み失敗")
        }
        
        if convertToPointsCheck {
            self.convertToPoints()
            print("計算おわ( ˘•ω•˘ )")
        }
        
       
        
        print("stopRec波形軽々\(readFile.points)")
        //let doubleAllay = readFile.points.map{ Double($0) }
        let readPoint = Data(fromArray: readFile.points)
        do {
            try readPoint.write(to: URL(fileURLWithPath:path_wave_array))
            
        } catch {
            //エラー処理
            print("できてんのか？")
        }
        
        
        
        let waveform = WaveformSave()
        waveform.waveFormAddress = waveformAddress
        
        do {
            try realm.write {
                realm.add(waveform)
            }
            print("波形データ保存成功")
        } catch {
            print("失敗っす")
        }
        
        //readFile.pointsをそのまま保存、アドレスはRealmに保存
        

                
    }
}


//MARK:-
//MARK:protcol
extension MainViewController: ParameterDrawDelegate {
    func pageViewJudgment(bool: Bool) {
        swipeJudge = bool
    }
    
    
    func startTimeget() {
        var seekPoint:Int!
        if let nodeTime = audioFilePlayer.lastRenderTime {
            let playerTime = audioFilePlayer.playerTime(forNodeTime: nodeTime) //Player Timeline形式に変換
            currentTime = (Double(playerTime!.sampleTime) / sampleRate) + self.offset//現在の再生時間を秒で取得
            //self.offset = currentTime
            seekPoint = Int(currentTime * 10)
            kurukuruView.value = seekPoint
            print("通り過ぎてる")
        } else {
            seekPoint = Int(duration * 0)
            kurukuruView.value = seekPoint
            print("通り過ぎてる2")
        }
        
    }
    
    func startTimeChange(time:Double) {
        
        seekCheck = true
        if audioFile == nil {
            return
        }
        //ボリューム操作
        var startTime: Double = time
        
        if startTime <= 0 {
            startTime = 0
        }   else if startTime > duration {
            startTime = duration
        }
        
        waveFormView.startTimepoint = Int(startTime / duration * 147.0)
        waveFormView.seekTimepoint = Int(startTime / duration * 147.0)
        print("waveFormView.startTimepoint\(waveFormView.startTimepoint))")
        waveFormView.setNeedsDisplay()
        touchBool = true
        //self.isPlay = false
        
        audioSeek(startTime)
        
    }
    
    func seekTimeChange(time: Double) {
        touchBool = false
        
        if audioFile == nil {
            return
        }
        //ボリューム操作
        var seekTime: Double = time
        
        if seekTime <= 0 {
            seekTime = 0
        }   else if seekTime > duration {
            seekTime = duration
        }
        //timeLabel.text = "\(startTime) / \(duration)"
        timeLabel.text = timeMinitsSecond(time: duration)
        seekLabel.text = timeMinitsSecond(time: seekTime)
        print("ととと")
        print("とととseektime\(seekTime)")
        print("とととduran\(duration)")
        waveFormView.seekTimepoint = Int(seekTime / duration * 148.0) //ここが147.0だったのがバグの原因( ˘•ω•˘ )
        print("ととと2")
        seekCheck = false
        waveFormView.setNeedsDisplay()
    }
}


extension MainViewController: RecDelegate {
    
    func recJudgement() {
        print("ポチ")
        if isPlay { stopPlay()}
        //判定してrec開始
        if isRec {
            stopRecord()
        } else {
            startRecord()
        }
        
        //判定してrecボタン アニメーション
        if isJudgement {
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 0.1
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false
            
            let animation1 = CABasicAnimation(keyPath: "transform.scale")
            animation1.fromValue = 0.75
            animation1.toValue = 1.0
            
            let animation2 = CABasicAnimation(keyPath: "cornerRadius")
            animation2.fromValue = 15.0
            animation2.toValue = 29.0
            
            animationGroup.animations = [animation1, animation2]
            self.recCenterInView.backgroundColor = UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.8)
            self.recView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
            self.recCenterInView.layer.add(animationGroup, forKey: nil)
            isJudgement = false
            
        } else {
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 0.1
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false
            
            let animation1 = CABasicAnimation(keyPath: "transform.scale")
            animation1.fromValue = 1.0
            animation1.toValue = 0.75
            
            let animation2 = CABasicAnimation(keyPath: "cornerRadius")
            animation2.fromValue = 29.0
            animation2.toValue = 15.0
            
            animationGroup.animations = [animation1, animation2]
            self.recCenterInView.backgroundColor = UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.55)
            self.recView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.0)
            self.recCenterInView.layer.add(animationGroup, forKey: nil)
            isJudgement = true
        }
    }
}

extension MainViewController: PlayDelegate {
    
    func playMusic() {
        if isPlay {
            stopPlay()
        } else {
            
            if (audioFile) == nil || currentTime == nil{
                return
            }
            print("タッチ\(String(describing: currentTime))")
            audioSeek(currentTime)
        }
    }
}

//MARK:-
//MARK: UITextViewDelegate
extension MainViewController: UITextViewDelegate {
    // 改行ボタンを押した時の処理
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //狙った行のrelm.audioTitleを上書きし　行に反映
        if (text == "\n") {
            try! realm.write {
                if textView.text == "" {
                    audioList[audioListNumber].audioTitle = "NoTitle"
                } else {
                    audioList[audioListNumber].audioTitle = textView.text //realmのオーディオタイトル変更
                }
            }
            let row = IndexPath(row: audioListNumber, section: 0)
            selectView.reloadRows(at: [row], with: .fade)
            
            isText = true
            self.textView.removeFromSuperview()
            return false
        }
        
        if (text == "/") {
            return false
        }
        if (text == ".") {
            return false
        }
        
        if self.textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 1.0)
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return true
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
   
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("コンテントオフセットidScroll\(scrollView.contentOffset)")
        
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let objs = audioList else {
            return 0
        }
        
        return objs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得する
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "aaa")
        // セルに表示する値を設定する
        let objs = audioList[indexPath.row]
        cell.textLabel!.text = objs.audioTitle
        cell.backgroundColor = UIColor.clear
        
        
        return cell
    }
 
    //index番目のセルが選択されたらそのセルの楽曲を再生
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioListNumber = indexPath.row
        offset = 0.0
        if startPlay() {
            print("成功！\(indexPath.row)")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
  //左スワイプしたらメニュー出てきて機能選べる
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        audioListNumber = indexPath.row
        //タイトル編集
        let normalAction = UIContextualAction(style: .normal,
                                              title: "name") { (action, view, completionHandler) in
                                               self.initTextView()
                                                completionHandler(true)
        }
        normalAction.backgroundColor = .blue
        
        //共有
        let activityAction = UIContextualAction(style: .normal,
                                              title: "activity") { (action, view, completionHandler) in
                                                let objs = self.audioList[indexPath.row]
                                                var fileString = ""
                                                if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
                                                    fileString = dir.appendingPathComponent(objs.audiofileAddres).path
                                                }
                                                let fileURL = URL(fileURLWithPath: fileString)
                                                
                                                print("ファイ\(fileURL)")
                                                    let activity = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                                                    self.present(activity, animated: true, completion: nil)
                                                
                                                completionHandler(true)
        }
        activityAction.backgroundColor = .lightGray
        
        //delete
        let destructiveAction = UIContextualAction(style: .destructive,
                                                   title: "delete") { (action, view, completionHandler) in
                                                    
                                                    let objs = self.audioList[indexPath.row]
                                                    let objsWave = self.waveformList[indexPath.row]

                                                    var filePath = ""
                                                    var filePathWave = ""
                                                    
                                                    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
                                                        filePath = dir.appendingPathComponent(objs.audiofileAddres).path
                                                    }
                                                    
                                                    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
                                                        filePathWave = dir.appendingPathComponent(objsWave.waveFormAddress).path
                                                    }
                                                    
                                                    
                                                    let manager = FileManager()
                                                    try! manager.removeItem(atPath: filePath)
                                                    try! manager.removeItem(atPath: filePathWave)
                                                    try! self.realm.write {
                                                        self.realm.delete(objs)
                                                        self.realm.delete(objsWave)
                                                    }
                                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                                    completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [destructiveAction, normalAction, activityAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = UIColor.init(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 1.0)
    }


 }

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionPort(_ input: AVAudioSession.Port) -> String {
	return input.rawValue
}


extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func startPick() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.startCamera()
        })
        ac.addAction(UIAlertAction(title: "PhotoLibrary", style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        ac.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        ac.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(ac, animated: true)
        
    }
    
    private func startCamera() {
        let sourceType: UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        } else {
            //label.text = "error"
            print("ぱぱぱ")
        }
    }
    
    private func openPhotoLibrary() {
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.navigationBar.backgroundColor = UIColor(red: 177/255.0, green: 23/255.0, blue: 23/255.0, alpha: 1.0);
            self.present(cameraPicker, animated: true, completion: nil)
            print("オープ〜ん！")
           // label.text = "Tap the [Start] to save a picture"
        } else {
            //label.text = "error"
            print("えらーやで〜")
        }
    }
   
    
    // MARK: ImageVicker Delegate Methods
    // called when image picked
    
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        guard let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            return
        }
        backGroundImageView.contentMode = .scaleAspectFit
        //backGroundImageView.image = pickedImage
        imagePicker.dismiss(animated: true, completion: nil)
        let vc: TrimImageVC = TrimImageVC.instantiateFromStoryboard()
        vc.delegate = self
        vc.prepareView(image: pickedImage)
        
        self.recCenterInView.removeFromSuperview()
        self.imageView.removeFromSuperview()
        self.startButton.removeFromSuperview()
        self.present(vc, animated: true)
        
    }
    
   
}

extension MainViewController: ImageChangeDelegate {
    func imageChange() {
        //backGroundImageView.contentMode = .scaleAspectFit
        //backGroundImageView.image = image
        self.loadView()
        self.viewDidLoad()
        
        /*
        loadImage()
        initSelectView()
        initKurukuru()
        initRecButton()
        initPlayButyton()
        initImagePicker()
        initWaveFormView()
        initTimelabel()
        */
    }
    
   
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


//[Double] ⇄ Data間を滑らかに変換する
extension Data {

    init<T>(fromArray values: [T]) {
        var values = values
        var myData = Data()
        
        for n in 0..<values.count {
            withUnsafePointer(to:&values[n], { (ptr: UnsafePointer<T>) -> Void in
                myData += Data( buffer: UnsafeBufferPointer(start: ptr, count: 1))
            })
        }
        self.init(myData)
        print("通貨")
    }

    func toArray<T>(type: T.Type) -> [T] {
        let value = self.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: T.self)
        }
        return [T](UnsafeBufferPointer(start: value, count: self.count / MemoryLayout<T>.stride))
    }

}

extension Notification.Name {
    static let userPresetsChanged = Notification.Name("userPresetsChanged")
}
