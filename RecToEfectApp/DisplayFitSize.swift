//
//  DisplayFitSize.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/02/27.
//  Copyright © 2019 新村彰啓. All rights reserved.
//
import  UIKit

let dounSize = 50
let downSize12Pro = 10
let downSize12ProMax = -20
let imagedoun:Double = 161
let imagedown12Pro:Double = 121


struct iPhone12ProMax {
    static let screenSize = CGSize(width: 428.0, height: 926.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 428, height: 926 - 399))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 428, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 428/2 - 46, y: 722 - downSize12ProMax, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 428/5*4 - 40, y: 730 - downSize12ProMax, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 428/5 - 40, y: 730 - downSize12ProMax, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 700 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}


struct iPhone12Pro {
    static let screenSize = CGSize(width: 390.0, height: 844.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 390, height: 844 - 399))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 10, y: 30, width: 390, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 390/2 - 46, y: 662 - downSize12Pro, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 390/5*4 - 40, y: 670 - downSize12Pro, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 390/5 - 40, y: 670 - downSize12Pro, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedown12Pro, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}

struct iPhoneXSMaxR {
    static let screenSize = CGSize(width: 414.0, height: 896.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 497))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 167, y: 722 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 295, y: 730 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 730 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}



struct iPhoneXS {
    static let screenSize = CGSize(width: 375.0, height: 812.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 375, height: 407))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 0, y: 30, width: 375, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 145, y: 642 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 260, y: 650 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 40, y: 650 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 265, y: 575 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 9, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 292, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 329, height: 812))
    static let swipeArea = kurukuruView.frame.origin.y
}


struct iPhone678Plus {
    static let screenSize = CGSize(width: 414.0, height: 736.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 397))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 10, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 160, y: 617 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 275, y: 625 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 625 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 278, y: 525 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 9, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 330, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 736))
    static let swipeArea = kurukuruView.frame.origin.y
}
//
struct iPhone678 {
    static let screenSize = CGSize(width: 375.0, height: 667.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 375, height: 330))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 2, y: 30, width: 375, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 145, y: 539 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 263, y: 547 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 37, y: 547 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 267, y: 455 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 9, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 292, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 329, height: 667))
    static let swipeArea = kurukuruView.frame.origin.y
}


struct iPhoneSE {
    static let screenSize = CGSize(width: 320.0, height:568.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 110, width: 320, height: 250))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 0, y: 25, width: 320, height: 80))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 112, y: 450 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 218, y: 458 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 20, y: 458 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 222, y: 360 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 9, y: 67, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 320 - 82, y: 67, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 568))
    static let swipeArea = kurukuruView.frame.origin.y
}
//


struct iPad7_9 {
    static let screenSize = CGSize(width: 768.0, height: 1024.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 497))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 167, y: 722 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 295, y: 730 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 730 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}

struct iPad10_2 {
    static let screenSize = CGSize(width: 810.0, height: 1080.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 497))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 167, y: 722 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 295, y: 730 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 730 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}

struct iPad10_5 {
    static let screenSize = CGSize(width: 834.0, height: 1112.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 497))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 167, y: 722 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 295, y: 730 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 730 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}

struct iPad11_0 {
    static let screenSize = CGSize(width: 834.0, height: 1194.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 497))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 167, y: 722 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 295, y: 730 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 730 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}

struct iPad12_9 {
    static let screenSize = CGSize(width: 1024.0, height: 1366.0)
    
    static let selectView = CustouTableView(frame: CGRect(x: 0, y: 130, width: 414, height: 497))
    static let waveFormView = DrawWaveform(frame: CGRect(x: 22, y: 30, width: 414, height: 100))
    static let kurukuruView = KurukuruUI(frame: CGRect(x: 167, y: 722 - dounSize, width: 92, height: 92))
    static let playButton = PlayButton(frame: CGRect(x: 295, y: 730 - dounSize, width: 80, height: 80))
    static let recView = RecordButton(frame: CGRect(x: 50, y: 730 - dounSize, width: 80, height:80))
    static let imageButton = UIButton(frame: CGRect(x: 300, y: 655 + imagedoun, width: 75.0, height: 63.0 * 0.6))
    static let seekLabel = UILabel(frame: CGRect(x: 0, y: 84, width: 94, height: 15))
    static let timeLabel = UILabel(frame: CGRect(x: 305, y: 84, width: 75, height: 15))
    static let topView = UIView(frame: CGRect(x: 0, y: 0, width: 362, height: 896))
    static let swipeArea = kurukuruView.frame.origin.y
}
