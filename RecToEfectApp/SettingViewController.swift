//
//  SettingViewController.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/05/16.
//  Copyright © 2019 新村彰啓. All rights reserved.
//

import UIKit
import RealmSwift



class SettingViewController: UIViewController {
    
    @IBOutlet weak var backGroundImageView: UIImageView!
    
    var selectView: CustouTableView!
    let realm = try! Realm()
    var config = Realm.Configuration()
    
    var topView:UIView!
    var filterView:UIView!
    var plivacypolicyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blue
        
        
        //self.backGroundImageView.isUserInteractionEnabled = true
        loadImage()
        initSelectView()
        initFilterVIew()
        initTopVIew()
        initPlapoliButton()
        // Do any additional setup after loading the view.
        
        
    }
    
    
    @objc func pushButton(_ sender: UIButton){
        //外部ブラウザでURLを開く
        let url = NSURL(string: "https://scrapbox.io/Pickout/Privacy_policy")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        print("プラポリ")
    }
    
    func initPlapoliButton() {
        self.plivacypolicyButton = UIButton(frame: CGRect(x: 10, y: 100, width: 150, height: 50))
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
        self.view.addSubview(self.plivacypolicyButton)
    }
    
    func initFilterVIew() {
        let screenSz:CGSize = UIScreen.main.nativeBounds.size
        filterView = UIView(frame: CGRect(x: 0, y: 0, width: screenSz.width, height: screenSz.height))
        filterView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        self.backGroundImageView.addSubview(filterView)
        
    }
    
    func initTopVIew() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
            topView = iPhoneXSMaxR.topView
            print("iPhoneXS Max Display")
            
        case iPhoneXS.screenSize: //iPhoneXS
            topView = iPhoneXS.topView
            print(" iPhoneXS Display")
            
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            topView = iPhone678Plus.topView
            print("iPhone6+, 7+, 8+ Display")
            
        case iPhone678.screenSize: //iPhone6, 7, 8
            topView = iPhone678.topView
            print("iPhone6, 7, 8 Display")
            
        case iPhoneSE.screenSize://iPhone5, SE
            topView = iPhoneSE.topView
            print("iPhone5, SE Display")
            
            
        case iPad7_9.screenSize:
            topView = iPad7_9.topView
                print("iPad7_9")
                
        case iPad10_2.screenSize:
            topView = iPad10_2.topView
                print("iPad10_2")
                
        case iPad10_5.screenSize:
            topView = iPad10_5.topView
                print("iPad10_5")
               
        case iPad11_0.screenSize:
            topView = iPad11_0.topView
                print("iPad11_0")
            
        case iPad12_9.screenSize:
            topView = iPad12_9.topView
            print("iPad12_9")
            
        default:
            print("NoHit")
        }
        
        topView.backgroundColor = UIColor(red: 35 / 255.0, green: 35 / 255.0, blue: 51 / 255.0, alpha: 0.95)
        
        topView.isUserInteractionEnabled = false
        self.backGroundImageView.addSubview(topView)
        
    }
    
    func initSelectView() {
        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
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
            
        default:
            print("NoHit")
        }
        
        selectView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.55)
        
        selectView.rowHeight = 85
        selectView.isUserInteractionEnabled = false
        self.backGroundImageView.addSubview(selectView)
    }
    
    func loadImage() {
        if realm.objects(ImageSave.self).count == 1 {
            let imageSaveLoad = realm.objects(ImageSave.self).first!
            backGroundImageView.image = UIImage(data: imageSaveLoad.imageData)
        } else {
            backGroundImageView.image = UIImage(named: "flower")
            
        }
    }

}



