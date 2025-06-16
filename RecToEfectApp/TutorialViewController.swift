//
//  TutorialViewController.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/09/28.
//  Copyright © 2019 新村彰啓. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController {

    var pageViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.dataSource = self

        let firstViewController: FirstViewController = storyboard!.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        let secondViewController: SecondViewController = storyboard!.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        let thirdViewController: ThirdViewController = storyboard!.instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController
        
        pageViewControllers = [firstViewController,secondViewController,thirdViewController]
        //UIPageViewControllerに表示対象を設定
        self.setViewControllers([pageViewControllers[0]], direction: .forward, animated: false, completion: nil)
        
            }
    
    override func viewDidLayoutSubviews() {
        let v = self.view
        let subviews = v?.subviews
        if subviews?.count == 2 {
            var sv:UIScrollView?
            var pc:UIPageControl?
            for t in subviews! {
                if t is UIScrollView {
                    sv = t as? UIScrollView
                } else {
                    pc = t as? UIPageControl
                }
            }
            if(sv != nil && pc != nil) {
                sv?.frame = (v?.bounds)!
                v?.bringSubviewToFront(pc!)
            }
        }
        super.viewDidLayoutSubviews()
    }

    func getFirst() -> FirstViewController {
        return storyboard!.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        
       }
    
    func getSecond() -> SecondViewController {
        return storyboard!.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
    }

    func getThird() -> ThirdViewController {
        return storyboard!.instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController
    }

       override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
       }
}


extension TutorialViewController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pageViewControllers.firstIndex(of: viewController)
        if index == 0 {
            //1ページ目の場合は何もしない
            return nil
        } else {
            //1ページ目の意外場合は1ページ前に戻す
            return pageViewControllers[index!-1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        //左にスワイプした場合に表示したいviewControllerを返す
        //ようはページを進める
        //今表示しているページは何ページ目か取得する
        let index = pageViewControllers.firstIndex(of: viewController)
        if index == pageViewControllers.count-1 {
            //最終ページの場合は何もしない
            return nil
        } else {
            //最終ページの意外場合は1ページ進める
            return pageViewControllers[index!+1]
        }
        
    }
    
    func presentationCount(for: UIPageViewController) -> Int {
        return pageViewControllers.count
    }

    func presentationIndex(for: UIPageViewController) -> Int {
       
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = pageViewControllers.firstIndex(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
}
