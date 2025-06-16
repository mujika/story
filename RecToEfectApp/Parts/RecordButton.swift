//
//  RecordButtonDraw.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/03/22.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//

import UIKit

protocol RecDelegate {
    func recJudgement()
}

class RecordButton: UIView {
    
    var delegate: RecDelegate!
    
    let parameterCenter = CGPoint(x: 40, y: 40)
    let parameterR:CGFloat = 39
    var circle: UIBezierPath!
    var touchJudge = true
    var circleColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.5)
    override func draw(_ rect: CGRect) {
        
        
        circle = UIBezierPath(arcCenter: parameterCenter, radius: parameterR , startAngle: CGFloat(Double.pi/2 + Double.pi/8), endAngle: CGFloat(Double.pi/2 - Double.pi/8), clockwise: true)
        
        
        circleColor.setStroke()
        circle.lineCapStyle = .round
        circle.lineWidth = 2
        circle.stroke()
        
    }
    
    
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate.recJudgement()
        if touchJudge {
            circleColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.0)
            touchJudge = false
            self.setNeedsDisplay()
            
        } else {
            circleColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.5)
            touchJudge = true
            self.setNeedsDisplay()
        }
        
        
            
        
    }
    
}
