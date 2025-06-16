//
//  TrimImageVC.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/02/05.
//  Copyright © 2019 新村彰啓. All rights reserved.
//

import UIKit
import RealmSwift

protocol ImageChangeDelegate: AnyObject {
    func imageChange()
   // func imageChangeCancel()
}


class TrimImageVC: UIViewController {
 
    private var scrollView: UIScrollView!
    private var imageView : UIImageView!
    private var image : UIImage!
    weak var delegate: ImageChangeDelegate?
    
    var imageChangeButton: UIButton!
    var trimImageButton: UIButton!
    var statasBar: UIView!
    
    //skeletonParts
    let startButton = UIImageView(frame: CGRect(x: 15, y: 26, width: 27, height: 27))
    var kurukuruView: KurukuruUI!
    var kurukuruImageView : UIImageView!
    var playButton: PlayButton!
    var recView:RecordButton!
    var recCenterInView:UIView!
    var selectView: UITableView!
    var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorChange()
        // ImageViewを準備
        self.imageView = UIImageView(image: self.image)
        self.view.backgroundColor = .white
        scrollViewInit()
        setZoomScale()
        buttonInit()
        skeletonPartsInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    func colorChange() {
        
        //グラデーションをつける
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
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
        self.view.layer.insertSublayer(gradientLayer,at:0)
    }
    
    
    //MARK:-
    //MARK:設置系
    func scrollViewInit() {
        // ScrollViewを準備
        scrollView = CropScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scrollView.center = view.center
        scrollView.delegate = self
        
        // ImageViewとScrollViewをビューに追加
        scrollView.addSubview(self.imageView)
        view.addSubview(scrollView)
    }
    
    func buttonInit() {
        let size = view.frame.width * 0.2
        
        statasBar = UIView(frame: CGRect(x: 0, y: 50, width: view.frame.width , height: size * 0.5))
        //取り込むボタンの表示
        
        //条件分岐でディスプレイごとに調整必　　あと写真選択をキャンセルした時にもとの写真表示がおかしくなる
       // imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.75), y: 50, width: size, height: size * 0.5))
        
        
        //imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.5), y: 50, width: size, height: size * 0.5))
        
        switch UIScreen.main.bounds.size {
            
        
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max R
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.75), y: 50, width: size, height: size * 0.5))
                print("iPhoneXS Max Display")
                
        case iPhoneXS.screenSize: //iPhoneXS
                //レコードボタン外から１層め
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.75), y: 50, width: size, height: size * 0.5))
                print(" iPhoneXS Display")
              
        case iPhone678Plus.screenSize: //iPhone6+,7+,8+
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.75), y: 50, width: size, height: size * 0.5))
                print("iPhone6+, 7+, 8+ Display")
                
        case iPhone678.screenSize: //iPhone6, 7, 8
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.75), y: 50, width: size, height: size * 0.5))
                print("iPhone6, 7, 8 Display")
                
        case iPhoneSE.screenSize://iPhoneSE
            //レコードボタン外から１層め
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.75), y: 50, width: size, height: size * 0.5))
                print("iPhoneSE Display")
            
        case iPad7_9.screenSize:
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.69), y: 50, width: size, height: size * 0.5))
             print("iPad7_9")
             
        case iPad10_2.screenSize:
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.645), y: 50, width: size, height: size * 0.5))
             print("iPad10_2")
             
        case iPad10_5.screenSize:
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.62), y: 50, width: size, height: size * 0.5))
             print("iPad10_5")
             
        case iPad11_0.screenSize:
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.618), y: 50, width: size, height: size * 0.5))
             print("iPad11_0")
             
        case iPad12_9.screenSize:
            imageChangeButton = UIButton(frame: CGRect(x: (view.frame.width * 0.47), y: 50, width: size, height: size * 0.5))
             print("iPad12_9")
             
         default:
             print("NoHit")
         }

        imageChangeButton.setTitle("save", for: UIControl.State.normal)
        imageChangeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        imageChangeButton.setTitleColor(UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7), for: UIControl.State.normal)
        imageChangeButton.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        imageChangeButton.layer.cornerRadius = 8
        imageChangeButton.layer.borderColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).cgColor
        imageChangeButton.layer.borderWidth = 1
        imageChangeButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        //imageChangeButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageChangeButton)
        
        trimImageButton = UIButton(frame: CGRect(x: 25, y: 50, width: size, height: size * 0.5))
        trimImageButton.setTitle("cancel", for: UIControl.State.normal)
        trimImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        trimImageButton.setTitleColor(UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7), for: UIControl.State.normal)
        trimImageButton.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        trimImageButton.layer.cornerRadius = 8
        trimImageButton.layer.borderColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).cgColor
        trimImageButton.layer.borderWidth = 1
        trimImageButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        self.view.addSubview(trimImageButton)
    }
    
    
    func skeletonPartsInit() {
        
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
            
            
        default:
            print("NoHit")
        }
        kurukuruView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        kurukuruView.layer.cornerRadius = 46
        kurukuruView.isUserInteractionEnabled = false
        kurukuruView.clipsToBounds = true //layer.cornerRadiusのコーナーを丸め
        view.addSubview(kurukuruView)
        
        let image1:UIImage = #imageLiteral(resourceName: "Kurukuru")
        let cw = 70
        kurukuruImageView  = UIImageView(frame: CGRect(x: (92 - cw) / 2, y: (92 - cw) / 2, width: cw, height: cw))
        kurukuruImageView.image = image1
        kurukuruView.addSubview(kurukuruImageView)
        
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
            
        default:
            print("NoHit")
        }
        playButton.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        playButton.layer.cornerRadius = 40
        playButton.clipsToBounds = true
        playButton.isUserInteractionEnabled = false
        
        
        startButton.image = UIImage(named: "StartButton")
        
        
        
        playButton.addSubview(startButton)
        view.addSubview(playButton)
        
        //レコードボタン外から１層め
        switch UIScreen.main.bounds.size {
            
        case iPhoneXSMaxR.screenSize: //iPhoneXS Max
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
            
        default:
            print("NoHit")
        }
        recView.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        recView.layer.cornerRadius = 40   // 右上の角と左上の角を丸くする
        recView.clipsToBounds = true
        recView.isUserInteractionEnabled = false
        
        //レコードボタン（アニメーション部分）
        self.recCenterInView = UIView(frame: CGRect(x: 11, y: 11, width: 58, height:58))
        self.recCenterInView.backgroundColor = UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.6)
        self.recCenterInView.layer.cornerRadius = 29
        
        self.view.addSubview(recView)
        recView.addSubview(self.recCenterInView)
        
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
        selectView.isUserInteractionEnabled = false
        selectView.rowHeight = 85
        selectView.isUserInteractionEnabled = false
        
        self.view.addSubview(selectView)
        
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
            
        default:
            print("NoHit")
        }
        imageButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //button.titleLabel?.textColor = UIColor.black
        imageButton.setTitleColor(UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7), for: UIControl.State.normal)
        imageButton.titleLabel?.numberOfLines = 0
        imageButton.titleLabel?.textAlignment = .center
        imageButton.setTitle("BackgroundImage", for: UIControl.State.normal)
        imageButton.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 29/255.0, alpha: 0.25)
        
        imageButton.layer.cornerRadius = 8
        
        imageButton.layer.borderColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).cgColor
        imageButton.layer.borderWidth = 1
        imageButton.isUserInteractionEnabled = false
        view.addSubview(imageButton)
    }
    
    
    
    //MARK:-
    //MARK:動作系
    
    private func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = min(widthScale, heightScale)
    }
    
    @objc func didTapConfirmButton() {
        // クロップ
        let width = scrollView.bounds.width
        let height = scrollView.bounds.height
        let x = scrollView.bounds.origin.x
        let y = scrollView.bounds.origin.y
        let cropBounds = CGRect(x: x, y: y, width: width, height: height)
        let visibleRect = imageView.convert(cropBounds, from: scrollView)
        
        // 画像生成
        UIGraphicsBeginImageContext(visibleRect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.black.cgColor)
        let backRect = CGRect(x: 0, y: 0, width: visibleRect.width, height: visibleRect.height)
        context?.fill(backRect)
        let drawRect = CGRect(x: -visibleRect.origin.x, y: -visibleRect.origin.y, width: image!.size.width, height: image!.size.height)
        image!.draw(in: drawRect)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 呼び出し元に渡す
        saveImage(image: croppedImage)
        
        recCenterInView.removeFromSuperview()
        imageView.removeFromSuperview()
        startButton.removeFromSuperview()
        delegate?.imageChange()
        self.dismiss(animated: true)
    }
    
    @objc func dismissSelf() {
        recCenterInView.removeFromSuperview()
        imageView.removeFromSuperview()
        startButton.removeFromSuperview()
        delegate?.imageChange()
        self.dismiss(animated: true)
    }
    
    func prepareView(image: UIImage) {
        self.image = image
    }
    
    //realm画像保存
    func saveImage(image: UIImage) {
        
        let imageSave = ImageSave()
        let realm = try! Realm()

        if realm.objects(ImageSave.self).count == 1 {
            let imageSaveLoad = realm.objects(ImageSave.self).first!
            do {
                try realm.write {
                    realm.delete(imageSaveLoad)
                }
            } catch {
                print("失敗っす")
            }
        }
            

        imageSave.imageData = image.pngData()!
        do {
            try realm.write {
                realm.add(imageSave)
            }
        } catch {
            print("失敗っす")
        }
    }
}


extension TrimImageVC: UIScrollViewDelegate, UITableViewDataSource {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        //scrollView.backgroundColor = UIColor(red: 5.0, green: 7.0, blue: 29.0, alpha: 1.0)
        
    }
    
    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        //let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        // セルに表示する値を設定する
        //let objs = audioList[indexPath.row]
        // cell.textLabel!.text = objs.audioTitle
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "aaa")
        
        return cell
    }

    
    
}


