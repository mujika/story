//
//  AppDelegate.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2018/06/03.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//

import UIKit
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController:MainViewController!

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           // Override point for customization after application launch.
           //アプリ起動中はスリープしない
           UIApplication.shared.isIdleTimerDisabled = true
           
           //使用するStoryBoardのインスタンス化
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
            // UserDefaultsにbool型のKey"launchedBefore"を用意
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

            if(launchedBefore == true) {
                //動作確認のために1回実行ごとに値をfalseに設定し直す
                //UserDefaults.standard.set(false, forKey: "launchedBefore")
                print("初回起動でない")
            } else { //起動を判定するlaunchedBeforeという論理型のKeyをUserDefaultsに用意
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                print("初回起動時")
                //チュートリアル用のViewControllerのインスタンスを用意してwindowに渡す
               
                let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = tutorialVC
             
            }
           
           return true
       }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.pathExtension == "wav" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let audioSaveData = AudioSave()
            audioSaveData.audiofileAddres = url.path
            audioSaveData.audioTitle = url.lastPathComponent
            
            print(audioSaveData.audiofileAddres )
            print(audioSaveData.audioTitle)
            //delegate.addAudioItem(audio: audioSaveData)
            ///工事中
            do {
                try appDelegate.mainViewController.realm.write {
                    appDelegate.mainViewController.realm.add(audioSaveData)
                }
            } catch {
                print("失敗っす")
            }
            
        
        appDelegate.mainViewController.selectView.reloadData()
            
        }
        return true
        
    }
 

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }



}
