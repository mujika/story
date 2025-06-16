//
//  ThirdViewController.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/10/08.
//  Copyright © 2019 新村彰啓. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var enjoyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.view.backgroundColor = UIColor.green
    }
    
    @IBAction func enjoyChage(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)//遷移先のStoryboardを設定
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController//遷移先のNavigationControllerを設定
        mainViewController.modalPresentationStyle = .fullScreen 
        self.present(mainViewController, animated: true, completion: nil)//遷移する
        
    }
    
//mainViewController
}
