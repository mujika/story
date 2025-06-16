//
//  PageViewController.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/05/15.
//  Copyright © 2019 新村彰啓. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
    
    var leftSwipe:UISwipeGestureRecognizer!
    var rightSwipe:UISwipeGestureRecognizer!
    
    var swipeArea: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([getFirst()], direction: .forward, animated: true, completion: nil)
        self.dataSource = nil
        
        displaySize()
        
        // スワイプを定義
        self.leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PageViewController.leftSwipeView(_:)))
        // レフトスワイプのみ反応するようにする
        self.leftSwipe.direction = .left
        // viewにジェスチャーを登録
        //view.addGestureRecognizer(self.leftSwipe)
 
        self.rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PageViewController.rightSwipeView(_:)))
        // ライトスワイプのみ反応するようにする
        self.rightSwipe.direction = .right
        // viewにジェスチャーを登録
        //self.view.addGestureRecognizer(self.rightSwipe)
        
    }
    
    func displaySize() {
        switch UIScreen.main.nativeBounds.size {
            
        case CGSize(width: 1242.0, height: 2688.0): //iPhoneXS Max
            self.swipeArea = iPhoneXSMax.swipeArea
            print("iPhoneXS Max Display")
            
        case CGSize(width: 1125.0, height: 2436.0): //iPhoneXS
            self.swipeArea = iPhoneXS.swipeArea
            print(" iPhoneXS Display")
            
        case CGSize(width: 828.0, height: 1792.0): //iPhoneXR
            self.swipeArea = iPhoneXR.swipeArea
            print("iphoneXR Display")
            
        case CGSize(width: 1242.0, height: 2208.0): //iPhone6+,7+,8+
            self.swipeArea = iPhone678Plus.swipeArea
            print("iPhone6+, 7+, 8+ Display")
            
        case CGSize(width: 750.0, height: 1334.0): //iPhone6, 7, 8
            self.swipeArea = iPhone678.swipeArea
            print("iPhone6, 7, 8 Display")
            
        case CGSize(width: 640.0, height: 1136.0)://iPhone5, SE
            self.swipeArea = iPhoneSE.swipeArea
            print("iPhone5, SE Display")
            
        default:
            print("NoHit")
        }
        
    }
    
    var tapPoint = CGPoint(x: 0, y: 0)
    
    
    /// レフトスワイプ時に実行される
    @objc func leftSwipeView(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            tapPoint = sender.location(in: self.view)
        
            self.setViewControllers([getFirst()], direction: .forward, animated: true, completion: nil)
            self.view.removeGestureRecognizer(leftSwipe)
            self.view.addGestureRecognizer(rightSwipe)
            
        }
        print("left Swipe")
    }
    
    /// ライトスワイプ時に実行される
    @objc func rightSwipeView(_ sender: UISwipeGestureRecognizer) {
        
        if sender.state == .ended {
            let storyboard: UIStoryboard = self.storyboard!
            let second = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
            let pageViewJudgment = second.swipeJudge
            
            self.tapPoint = sender.location(in: self.view)
            
            print("なぜ？\(pageViewJudgment)")
            if self.tapPoint.y < swipeArea {
                self.setViewControllers([getSecond()], direction: .reverse, animated: true, completion: nil)
                self.view.removeGestureRecognizer(rightSwipe)
                self.view.addGestureRecognizer(leftSwipe)
                
            }
        }
        print("right Swipe")
    }
    
    func getFirst() -> MainViewController {
        
        return storyboard!.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
    }
    
    func getSecond() -> SettingViewController {
        
        return storyboard!.instantiateViewController(withIdentifier: "settingViewController") as! SettingViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension PageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: MainViewController.self) {
            return getSecond()
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: SettingViewController.self) {
            return getFirst()
        } else {
            return nil
        }
        
    }
    
    
}
/*
protocol ContentChangeDelegete {
    func contentChange(content: CGPoint)
}
 */




