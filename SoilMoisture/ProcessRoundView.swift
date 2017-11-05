//
//  RoundView.swift
//  Assignment4
//
//  Created by Can Wang on 2/11/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//  Reference from: https://github.com/jamesdouble/JDProgressRoundView

import UIKit

class ProcessRoundView: UIView {
    
    var innerView:InnerView?
    var border:RoundLayer?
    
    init (frame: CGRect,howtoincrease t:types,ProgressColor c:UIColor,BorderWidth b:CGFloat, progress p: CGFloat) {
        super.init(frame: frame)
        
        border = RoundLayer(LineWidth: b)
        border?.DrawCircle(theBounds: self.frame, Stroke_Color: UIColor.black.cgColor,percent: 100.0)
        layer.addSublayer(border!)// draw the border of the round view
        
        var innerFrame:CGRect = self.frame
        innerFrame.origin.x = 0.0
        innerFrame.origin.y = 0.0
        if (t == .Water){            
            innerView = InnerView(frame: innerFrame, howtoincrease: t,ProgressColor: c,UNIT : "%")
            innerView?.ValueControl(progress: p)
        }else{
            innerView = InnerView(frame: innerFrame, howtoincrease: t,ProgressColor: c,UNIT : "ºC")
            innerView?.ValueControl(progress: p)
        }
        innerView?.DrawInnerLayer()
        self.addSubview(innerView!)// draw the inner layer of the round view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
