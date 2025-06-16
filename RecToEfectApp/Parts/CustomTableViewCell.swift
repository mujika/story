//
//  CustomTableViewCell.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/06/02.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let storyboard = UIStoryboard(name: "PageViewController", bundle: nil)
        
        let pageView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
        print("pvんfkjdんb\(String(describing: pageView.dataSource))")
        pageView.dataSource = nil
    }
    
    // 画像・タイトル・説明文を設定するメソッド
    func setCell(imageName: String, titleText: String, descriptionText: String) {
        print("setCell")
    }

}
