//
//  CropScrollView.swift
//  RecToEfectApp
//
//  Created by 新村彰啓 on 2019/02/08.
//  Copyright © 2019 新村彰啓. All rights reserved.
//

import UIKit

class CropScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        
        
        
        clipsToBounds = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        //layer.borderWidth = 1
        //layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
