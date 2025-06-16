//
//  PlayButtonDraw.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/05/31.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//

import UIKit

protocol PlayDelegate {
    func playMusic()
}

class PlayButton: UIView {
    
    var delegate: PlayDelegate!
    
    

    override func draw(_ rect: CGRect) {
        /*
        let playButton = UIBezierPath()
        
        let point1 = CGPoint(x: 17, y: 28)
        let point2 = CGPoint(x: 17, y: 52)
        let point3 = CGPoint(x: 37, y: 41)
        
        playButton.move(to: point1)
        playButton.addLine(to: point2)
        playButton.addLine(to: point3)
        playButton.close()
        playButton.lineJoinStyle = .miter
        UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.6).setStroke()
        playButton.lineWidth = 0
        UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.6).setFill() //塗りつぶしcolor
        playButton.fill()
        playButton.stroke()
        */
        let linepoint1 = CGPoint(x: 52, y: 30)
        let linepoint2 = CGPoint(x: 52, y: 50)
        let linepoint3 = CGPoint(x: 59, y: 30)
        let linepoint4 = CGPoint(x: 59, y: 50)
        
        let poseline1 = UIBezierPath()
        let poseline2 = UIBezierPath()
        
        poseline1.move(to: linepoint1)
        poseline1.addLine(to: linepoint2)
        poseline1.close()
        poseline1.lineWidth = 3
        poseline2.move(to: linepoint3)
        poseline2.addLine(to: linepoint4)
        poseline2.close()
        poseline2.lineWidth = 3
        UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 0.6).setStroke()
        poseline1.stroke()
        poseline2.stroke()
        
        
        
        let parameterCenter = CGPoint(x: 40, y: 40)
        let parameterR:CGFloat = 39
        let circle = UIBezierPath(arcCenter: parameterCenter, radius: parameterR , startAngle: CGFloat(Double.pi/2 + Double.pi/8), endAngle: CGFloat(Double.pi/2 - Double.pi/8), clockwise: true)
        
        let circleColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.5)
        circleColor.setStroke()
        circle.lineCapStyle = .round
        circle.lineWidth = 2
        circle.stroke()
    }
 
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate.playMusic()
    }

}
//57290.55
