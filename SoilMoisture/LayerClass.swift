//
//  LayerClass.swift
//  Assignment4
//
//  Created by Can Wang on 2/11/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//  Reference from: https://github.com/jamesdouble/JDProgressRoundView

import UIKit

// border class
class RoundLayer:CAShapeLayer{
    
    var halfSize:CGFloat = 0.0
    var desiredLineWidth:CGFloat = 13
    
    override init() {
        super.init()
        self.lineCap = "kCALineCapRound"
        self.lineJoin = "kCALineJoinRound"
        self.lineWidth = desiredLineWidth
    }
    
    init(LineWidth w:CGFloat) {
        super.init()
        self.lineCap = "kCALineCapRound"
        self.lineJoin = "kCALineJoinRound"
        self.lineWidth = w
        desiredLineWidth = w
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    func getPath(percent:CGFloat) -> CGPath{
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:halfSize,y:halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(Double.pi * 1.5),
            endAngle:CGFloat(Double.pi * 1.5) + CGFloat(Double.pi * 2) * percent/100 ,
            clockwise: true)
        
        circlePath.lineCapStyle = .round
        circlePath.lineJoinStyle = .round
        
        return circlePath.cgPath
    }
    
    func DrawCircle(theBounds:CGRect,Stroke_Color:CGColor,percent:CGFloat){
        halfSize = min( theBounds.size.width/2, theBounds.size.height/2)
        let circlePath = getPath(percent: percent)
        self.path = circlePath
        self.lineCap = "kCALineCapRound"
        self.lineJoin = "kCALineJoinRound"
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = Stroke_Color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// inner layer class
class InnerLayer:CAShapeLayer{
    
    var halfSize:CGFloat = 0.0
    var parentInnerView:InnerView?
    var layeranimation:LayerAnimation?
    
    override init() {
        super.init()
    }
    
    init(ParentControll inner:InnerView) {
        super.init()
        parentInnerView = inner
    }
    
    func DrawCircle(theBounds:CGRect,FillingColor c:UIColor,percent:CGFloat){
        halfSize = min( theBounds.size.width/2, theBounds.size.height/2)
        let desiredLineWidth:CGFloat = 13
        let circlePath:CGPath = BezierPath.getPath(percent: percent, innerlayer: self, originalRect: theBounds)
        self.path = circlePath
        self.fillColor = c.cgColor
        self.strokeColor = UIColor.clear.cgColor
        self.lineWidth = desiredLineWidth
        if(parentInnerView?.increaseType == .Water)
        {
            let DownCircleMask:InnerLayer = InnerLayer()
            DownCircleMask.DrawCircle(theBounds: theBounds,FillingColor: c, percent: 100.0)
            self.mask = DownCircleMask
            layeranimation = LayerAnimation(innerlayer: self)
            tickAnimation(FillingColor: c, percent: percent)
        }
    }
    
    func tickAnimation(FillingColor c:UIColor,percent:CGFloat){
        if(parentInnerView?.increaseType == .Water){
            layeranimation?.WaterLayerAnimation(FillingColor: c, percent: percent)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
