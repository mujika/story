//
//  KurukuruUI.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/05/26.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//

import UIKit

protocol ParameterDrawDelegate {
    func startTimeChange(time: Double)
    func seekTimeChange(time: Double)
    func startTimeget()
}




private let inWheelRadius: CGFloat = 0.25
private let outWheelRadius: CGFloat = 0.5
private let clickThreshold: CGFloat = 0.1

class KurukuruUI: UIView {

    var circle:UIBezierPath!
    var auxiliary: UIBezierPath!
    var touchLocation = CGPoint(x: 46, y: 46)
    var delegate: ParameterDrawDelegate! //パラメーターの変化を以上
    var kurukuruCount = 1
    var radian:CGFloat!
    var touchPoint:CGPoint!
    let parameterR:CGFloat = 45  //パラメーター半径
    let linewidth:CGFloat = 4    //パラメーターラインwidth
    let parameterCenter = CGPoint(x: 46, y: 46) //パラメーター半径
    
    var curAngle: CGFloat = .nan
    var value: Int = 0
    var feedbackGenerator: UISelectionFeedbackGenerator? = nil
    
    var startTime = 0.0
    var seekTime = 0.0
    
    
    override func draw(_ rect: CGRect) {
        
        
        circle = UIBezierPath(arcCenter: parameterCenter, radius: parameterR , startAngle: CGFloat(Double.pi/2 + Double.pi/8), endAngle: CGFloat(Double.pi/2 - Double.pi/8), clockwise: true)
        
        auxiliary = UIBezierPath()
        auxiliary.move(to: parameterCenter)
        auxiliary.addLine(to: touchLocation)
        auxiliary.close()
        UIColor.red.setStroke()
        auxiliary.lineWidth = 2
            auxiliary.stroke()
        
        
        
        
        let circleColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.5)
        circleColor.setStroke()
        circle.lineCapStyle = .round
        circle.lineWidth = 2
        circle.stroke()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        superview?.touchesBegan(touches, with: event)//親Viewにタッチを伝える
        print("タツィ通過")
        if let touch = touches.first as UITouch? {
           // delegateGesture.removeGesture()
            delegate.startTimeget()
            
            let location = touch.location(in: self)
            self.touchPoint = location
            touchLocation = location
            
            if circle.contains(touchPoint) {
                /*
                 ここに円の論理変換処理を書く
                 */
                
            }
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
            if let a = getAngle(touch: touch) {
                curAngle = a
            }
            self.setNeedsDisplay()
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        superview?.touchesMoved(touches, with: event)
        if let touch = touches.first as UITouch? {
            let location = touch.location(in: self)
            /* touchPoint = location ← これいらないのポイント touchesBeganの時のみ入れることによってarcないで最初にタッチした時になる!!*/
            
            if value <= 0 {
                value = 0
            }
            
            
            if circle.contains(touchPoint) {
                /*
                 ここに円の論理変換処理を書く
                 */
                if let a = getAngle(touch: touch) {
                    if abs(a - curAngle) > clickThreshold {
                        if a - curAngle > .pi {
                            curAngle += 2 * .pi
                        }
                        else if curAngle - a > .pi {
                            curAngle -= 2 * .pi
                        }
                        //let newValue = max(0, min(100, value + Int((curAngle-a) / clickThreshold)))
                        let newValue = value + Int((curAngle-a) / clickThreshold)
                        curAngle = a
                        if newValue != value {
                            value = newValue
                            
                            let kurukuruTime = Double(value) * 0.1 //クルクルの回転感
                            startTime = kurukuruTime
                            seekTime = kurukuruTime
                            
                            feedbackGenerator?.selectionChanged()
                            feedbackGenerator?.prepare()
                            //self.setNeedsDisplay()
                            //delegate.startTimeChange(time: startTime)
                            delegate.seekTimeChange(time: seekTime)
                        }
                    }
                }
                
                
                
                touchLocation = location
                self.setNeedsDisplay()
                
            }
           
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesEnded(touches, with: event)
        feedbackGenerator = nil
        curAngle = .nan
        print("送信時間\(startTime)")
        delegate.startTimeChange(time: startTime)
        touchLocation = parameterCenter
      //  delegateGesture.addGesture()
        print("touchesEnded通過")
        self.setNeedsDisplay()
        self.value = 0
        print("\(value)")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesCancelled(touches, with: event)
        
        print("touchesCancelled通過")
    }
    
    func getAngle(touch: UITouch) -> CGFloat? {
        //let t = min(frame.height, frame.width)
        let point = touch.location(in: self)
        let x = point.x - 23
        let y = point.y - 23
        //let dist = sqrt(x*x + y*y)
        //let ans = t * inWheelRadius < dist && dist < t * outWheelRadius ? atan2(x, y) : nil
        let ans = atan2(x, y)
        return ans
    }
    

}
