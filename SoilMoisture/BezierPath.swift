//
//  BezierPath.swift
//  Assignment4
//
//  Created by Can Wang on 2/11/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//  Reference from: https://github.com/jamesdouble/JDProgressRoundView

import UIKit

//controll the display of the inner layer
class BezierPath{
    
    static func getPath(percent:CGFloat,innerlayer :InnerLayer,originalRect:CGRect) -> CGPath{
        
        let desiredLineWidth:CGFloat = 13
        
        var r:CGFloat!
        var s:CGFloat!
        var e:CGFloat!
        var circlePath:UIBezierPath = UIBezierPath()
        
        if(innerlayer.parentInnerView?.increaseType == .DownToTop){
            r = CGFloat(innerlayer.halfSize - 2 * (desiredLineWidth/2))
            s = CGFloat(CGFloat(Double.pi * 0.5) * (1 - percent/25))
            e = CGFloat(CGFloat(Double.pi * 0.5) * (1 + percent/25))
            
            circlePath = UIBezierPath(arcCenter: CGPoint(x:innerlayer.halfSize,y:innerlayer.halfSize),
                                      radius: r,
                                      startAngle: s,
                                      endAngle: e,
                                      clockwise: true)
            circlePath.fill()
            return circlePath.cgPath
            
        }else if(innerlayer.parentInnerView?.increaseType == .Water){
            let centerY = innerlayer.halfSize * (100.0 - percent)/50
            let steps = 200                 // Divide the curve into steps
            let stepX = (2 * innerlayer.halfSize - 2 * (desiredLineWidth/2))/CGFloat(steps) // find the horizontal step distance
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: innerlayer.halfSize * 2 ))
            path.addLine(to: CGPoint(x: 0, y: centerY))
            
            for i in 0...steps {
                let x = CGFloat(i) * stepX
                var y = 0.0
                if(innerlayer.layeranimation != nil){
                    y = (sin(Double(i + (innerlayer.layeranimation?.count)!) * 0.04) * 8) + Double(centerY)
                }else{
                    y = (sin(Double(i) * 0.04) * 8) + Double(centerY)
                }
                path.addLine(to: CGPoint(x: x, y: CGFloat(y)))
            }
            path.addLine(to: CGPoint(x: 2 * innerlayer.halfSize, y: 2 * innerlayer.halfSize))
            path.close()
            let fillColor = UIColor.blue
            fillColor.setFill()
            path.fill()
            return path.cgPath
        }
        
        r = CGFloat( innerlayer.halfSize - 2 * (desiredLineWidth/2) )
        s = CGFloat( CGFloat(Double.pi * 0.5) * (1 - percent/50))
        e = CGFloat( CGFloat(Double.pi * 0.5) * (1 + percent/50))
        
        circlePath = UIBezierPath(arcCenter: CGPoint(x:innerlayer.halfSize,y:innerlayer.halfSize),
                                  radius: r,
                                  startAngle: s,
                                  endAngle: e,
                                  clockwise: true)
        circlePath.fill()
        return circlePath.cgPath
    }
}
