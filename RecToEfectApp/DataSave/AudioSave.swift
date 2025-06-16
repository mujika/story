//
//  AudioSave.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/02/03.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//

import UIKit
import RealmSwift

class AudioSave: Object {

    @objc dynamic var audioTitle: String = ""
    @objc dynamic var audiofileAddres: String = "" //変わらないーオーディオアドレス　読み込み側でドキュメントより上のアドレスは取得してもらう

    
}
