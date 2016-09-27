//
//  ProgressView.swift
//  Pods
//
//  Created by nakajijapan on 4/26/15.
//
//

import UIKit

public class ProgressView: UIView {

    var progressLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
    }
    
    public override func draw(_ rect: CGRect) {
        self.createInitialProgressLayer()
        self.createProgressLayer()
    }
    
    func createInitialProgressLayer() {
        let startAngle = -M_PI_2
        let endAngle = M_PI_2 * 2 + M_PI_2
        let centerPoint = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        
        self.progressLayer = CAShapeLayer()
        self.progressLayer.path = UIBezierPath(
            arcCenter: centerPoint,
            radius: 20.0,
            startAngle: CGFloat(startAngle),
            endAngle: CGFloat(endAngle),
            clockwise: true
        ).cgPath
        self.progressLayer.backgroundColor = UIColor.clear.cgColor
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2).cgColor
        self.progressLayer.lineWidth = 4.0
        self.progressLayer.strokeStart = 0.0
        self.progressLayer.strokeEnd = 1.0
        self.layer.addSublayer(self.progressLayer)
    }
    
    func createProgressLayer() {
        let startAngle = -M_PI_2
        let endAngle = M_PI_2 * 2 + M_PI_2
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        self.progressLayer = CAShapeLayer()
        let bezierPath = UIBezierPath(arcCenter: centerPoint, radius: 20.0, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        progressLayer.path = bezierPath.cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = kCALineCapRound
        layer.addSublayer(self.progressLayer)
    }
    
    func animateCurveToProgress(progress: Float) {
        
        if progressLayer == nil {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = NSNumber(value: Float(self.progressLayer.strokeEnd))
        animation.toValue = NSNumber(value: progress)
        animation.duration = 0.05
        animation.fillMode = kCAFillModeForwards
        self.progressLayer.strokeEnd = CGFloat(progress)
        self.progressLayer.add(animation, forKey: "strokeEnd")
    }


}
