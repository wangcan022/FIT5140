//
//  innerView.swift
//  Assignment4
//
//  Created by Can Wang on 2/11/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//  Reference from: https://github.com/jamesdouble/JDProgressRoundView

import UIKit

enum types {
    case DownToTop
    case Water
}

class InnerView: UIView {

    var bgColor:UIColor!
    var unitString:String = "%"
    var increaseType:types = .DownToTop
    var progress:CGFloat = 0.0
    var progressLabel:UILabel?
    var progressInnerLayer:InnerLayer!
    var progressRoundLayer:RoundLayer!
    
    init(frame: CGRect,howtoincrease type:types,ProgressColor color:UIColor,UNIT u:String){
        super.init(frame: frame)
        bgColor = color
        unitString = u
        increaseType = type
        progress = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // pass moisture data
    func ValueControl(progress:CGFloat){
        self.progress = progress
    }
    
    // draw the inner layer of the round view
    func DrawInnerLayer(){
        progressInnerLayer = InnerLayer(ParentControll: self)
        progressInnerLayer.DrawCircle(theBounds: self.frame, FillingColor: bgColor ,percent: progress)
        layer.addSublayer(progressInnerLayer)
        
        let labelFrame:CGRect = CGRect(x: 0.0, y: 0.35 * self.frame.height, width: self.frame.width, height: self.frame.height * 0.3)
        progressLabel = UILabel(frame: labelFrame)
        progressLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.thin)
        progressLabel?.text = "\(progress)\(unitString)"
        progressLabel?.textAlignment = .center

        self.addSubview(progressLabel!)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
