//
//  DrawWaveform.swift
//  RecApp
//
//  Created by 新村彰啓 on 2018/05/23.
//  Copyright © 2018年 新村彰啓. All rights reserved.
//
import Foundation
import UIKit
import Accelerate

class DrawWaveform: UIView {

    var convertToPointsCheck = true
    var startTimepoint: Int = 0 //start位置0~147
    var seekTimepoint: Int = 0 //seek位置
    
    var aPath: UIBezierPath!
    var aPath2: UIBezierPath!
    
    var f: Int = 0
    
    var maxValue:CGFloat = 0
    var waveFit:CGFloat!
    var waveFit2:CGFloat!
    let waveRatio:CGFloat = 120
   

   //xは正方形間の距離であり、yは正方形の振幅である。
    override func draw(_ rect: CGRect) {
        if readFile.arrayFloatValues.count <= 147 {
            return
        }
        if convertToPointsCheck {
            self.convertToPoints()
        }
        
        f = 0
        
        aPath = UIBezierPath()
        aPath2 = UIBezierPath()
        
        aPath.lineWidth = 2.0
        aPath2.lineWidth = 2.0
        
        aPath.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height ))
        
        if readFile.points.count != 0 {
            
            maxValue = readFile.points.max()!
            if maxValue == 0.0 {
                maxValue = 0.0018
            }
            //iPhoneオーディオ maxvalue0.018664749011397362
            print("マックス！\(maxValue)")
            waveFit = 50 / maxValue
            waveFit2 = 30 / maxValue
        }
        
        //print("readFile.arrayFloatValues\(readFile.arrayFloatValues)")
        
        //let poinpo = readFile.points.map{CGFloat($0 * 10)}
        
        for _ in readFile.points {
            
            
            if startTimepoint > 147 {
                startTimepoint = 147
            }
            if seekTimepoint > 147 {
                startTimepoint = 147
            }
            
            if startTimepoint < seekTimepoint {
                
                drawLineColorSet(drawpoint: startTimepoint, color: UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0))
                drawLineColorSet(drawpoint: seekTimepoint, color: UIColor(red: 252/255.0, green: 113/255.0, blue: 159/255.0, alpha: 0.8))
            }
        
            if startTimepoint > seekTimepoint {
                drawLineColorSet(drawpoint: seekTimepoint, color: UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0))
                drawLineColorSet(drawpoint: startTimepoint, color: UIColor(red: 252/255.0, green: 113/255.0, blue: 159/255.0, alpha: 0.8)
                )
            }
            if startTimepoint == seekTimepoint {
                drawLineColorSet(drawpoint: startTimepoint, color: UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0))
            }
            
            
            //separation of points
            var x:CGFloat = 2.5
            aPath.move(to: CGPoint(x:aPath.currentPoint.x + x , y:aPath.currentPoint.y ))
            
            //Y is the amplitude
            
            //guitere用
            aPath.addLine(to: CGPoint(x:aPath.currentPoint.x  , y:aPath.currentPoint.y - (readFile.points[f] * waveFit) + CGFloat(-1.0)))

            aPath.close()
            f += 1
            x += 1
       }
        
            //If you want to stroke it with a Orange color
           // UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).set()
        
        if startTimepoint == 147 {
            UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0).set()
        } else {
            //If you want to stroke it with a Orange color
            UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).set()
        }
        aPath.stroke()
        //If you want to fill it as well
        aPath.fill()
        f = 0
        
        
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        
        //Reflection of waveform
        for _ in readFile.points{
           
            if startTimepoint < seekTimepoint {
                
                draw2LineColorSet(drawpoint: startTimepoint, color: UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0))
                draw2LineColorSet(drawpoint: seekTimepoint, color: UIColor(red: 252/255.0, green: 113/255.0, blue: 159/255.0, alpha: 0.8))
            }
            
            if startTimepoint > seekTimepoint {
                draw2LineColorSet(drawpoint: seekTimepoint, color: UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0))
                draw2LineColorSet(drawpoint: startTimepoint, color: UIColor(red: 252/255.0, green: 113/255.0, blue: 159/255.0, alpha: 0.8)
                )
            }
            if startTimepoint == seekTimepoint {
                draw2LineColorSet(drawpoint: startTimepoint, color: UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0))
            }
            
            var x:CGFloat = 2.5
            aPath2.move(to: CGPoint(x:aPath2.currentPoint.x + x , y:aPath2.currentPoint.y ))
            
            //Y is the amplitude
            //guiter用
            aPath2.addLine(to: CGPoint(x:aPath2.currentPoint.x  , y:aPath2.currentPoint.y - ((-1.0 * readFile.points[f]) * waveFit2 ) + CGFloat(1.0)))
            aPath2.close()
            f += 1
            x += 1
        }
        
        if startTimepoint == 147 {
            UIColor(red: 252/255.0, green: 33/255.0, blue: 79/255.0, alpha: 1.0).set()
        } else {
            //If you want to stroke it with a Orange color with alpha2
            UIColor(red: 239/255.0, green: 238/255.0, blue: 232/255.0, alpha: 0.7).set()
        
        }
        
        aPath2.stroke(with: CGBlendMode.normal, alpha: 0.5)
        
        //If you want to fill it as well
        aPath2.fill()
        f = 0
    }
    
    /// ラインの動きとカラーセット
    func drawLineColorSet(drawpoint: Int, color: UIColor) {
        if f == drawpoint {
            
            let aPathX = aPath.currentPoint.x
            let aPathY = aPath.currentPoint.y
            //If you want to stroke it with a Orange color
            color.set()
            aPath.stroke()
            //If you want to fill it as well
            aPath.fill()
            aPath = UIBezierPath()
            aPath.move(to: CGPoint(x:aPathX , y:aPathY))
        }
    }
    
    func draw2LineColorSet(drawpoint: Int, color: UIColor) {
        if f == drawpoint {
            
            let aPathX = aPath2.currentPoint.x
            let aPathY = aPath2.currentPoint.y
            //If you want to stroke it with a Orange color
            color.set()
            aPath2.stroke(with: CGBlendMode.normal, alpha: 0.5)
            //If you want to fill it as well
            aPath2.fill()
            aPath2 = UIBezierPath()
            aPath2.move(to: CGPoint(x:aPathX , y:aPathY))
        }
    }
    
    
    
    //配列のサイズを減らしてCGFloatに変換
    @objc func convertToPoints() {
        convertToPointsCheck = false
        print("マックス値\(String(describing: readFile.arrayFloatValues.max()))")
        let mapFile = readFile.arrayFloatValues.map{$0}
        print("audioFile.processingFormatmapfile \(mapFile.count)")
        print("audioFile.processingFormatmapfilemax \(String(describing: mapFile.max()))")
        /*ここから"audioFile.processingFormatmapfilemDoun1\(String(describing: downSampledData.max()))"の間に
         audioFile.processingFormatmapfilemax Optional(0.039449207)
         audioFile.processingFormatmapfilemDoun1Optional(0.0)
         になって失われてる( ˘•ω•˘ )
         245行目付近
         */
        
        var processingBuffer = [Float](repeating: 0.0,
                                       count: Int(mapFile.count))
        print("audioFile.processingFormatmapfilemax2 \(String(describing: mapFile.max()))")
        let sampleCount = vDSP_Length(mapFile.count)
        print("audioFile.processingFormatmapfilemax3 \(String(describing: mapFile.max()))")
        
        //vDSP_vabs：配列内のすべての要素の絶対値をとる
        //わるさしてる感ぱねぇ
        // convert do dB
        vDSP_vabs(mapFile, 1, &processingBuffer, 1, sampleCount)
        print("audioFile.processingFormatmapfilemaxp1 \(String(describing: processingBuffer.max()))")
        print("audioFile.processingFormatmapfilemax4 \(String(describing: mapFile.max()))")
        
        var multiplier = 1.0
        if multiplier < 1{
            multiplier = 1.0
        }
        
        //let samplesPerPixel = Int(148 * multiplier) //guiter用￥
        let samplesPerPixel = Int(Double(mapFile.count) / 147.0 * multiplier)
        print("audioFile.processingFormatmapfilesamplesPerPixel \(samplesPerPixel)")
        print("サンプルピクセル\(samplesPerPixel)")
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel),
                             count: Int(samplesPerPixel))
        
        var downSampledLength = 147 //Int(readFile.arrayFloatValues.count / samplesPerPixel)
        
        if mapFile.count == 0 {
            downSampledLength = 0
            print("ぜーろー")
        }
        var downSampledData = [Float](repeating:0.0,
                                      count:downSampledLength)
       
       ////////そもそもここでdownSampledDataが上書きされてないかも、、、いってるやん！！！！！！！！！
        vDSP_desamp(processingBuffer,
                    vDSP_Stride(samplesPerPixel),
                    filter,
                    &downSampledData,
                    vDSP_Length(downSampledLength),
                    vDSP_Length(samplesPerPixel))
        print("audioFile.processingFormatmapfilemapFile.count\(downSampledData.count)")
        print("audioFile.processingFormatmapfilemaxd \(String(describing: downSampledData.max()))")
        print("audioFile.processingFormatmapfilemaxp2 \(String(describing: processingBuffer.max()))")
        print("audioFile.processingFormatmapfilemDoun2\(mapFile.count)")
        print("processingBuffer\(processingBuffer.count)")
        print("vDSP_Stride(samplesPerPixel)\(vDSP_Stride(samplesPerPixel))")
        print("vDSP_Length(downSampledLength)\(vDSP_Length(downSampledLength))")
        print("vDSP_Length(samplesPerPixel)\(vDSP_Length(samplesPerPixel))")
 
        //print(vDSP_Stride(samplesPerPixel) * (vDSP_Length(downSampledLength) - 1) + vDSP_Length(samplesPerPixel))
//        readFileが波形データ？
        readFile.points = downSampledData.map{CGFloat($0)}
        var strin: String = ""
        for n in 0..<147 {
            strin += "、 \(readFile.points[n])"
        }
        print("audioFile.processingFormat7 \(String(describing: readFile.points.max()))")
        
        /*
         ここまで
         */
        print("audioFile.processingFormatmapfilemDoun1\(String(describing: downSampledData.max()))")
    }
}

struct readFile {
    static var arrayFloatValues:[Float] = []
    static var points:[CGFloat] = []
    
}

