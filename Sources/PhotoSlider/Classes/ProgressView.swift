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
        backgroundColor = UIColor.clear
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = UIColor.clear
    }
    
    public override func draw(_ rect: CGRect) {
        createInitialProgressLayer()
        createProgressLayer()
    }
    
    private func createInitialProgressLayer() {
        let startAngle = -Double.pi / 2.0
        let endAngle = Double.pi + 1.5
        let centerPoint = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(
            arcCenter: centerPoint,
            radius: 20.0,
            startAngle: CGFloat(startAngle),
            endAngle: CGFloat(endAngle),
            clockwise: true
            ).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2).cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
    }
    
    private func createProgressLayer() {
        let startAngle = -Double.pi / 2.0
        let endAngle = Double.pi + 1.5
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        progressLayer = CAShapeLayer()
        let bezierPath = UIBezierPath(arcCenter: centerPoint, radius: 20.0, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        progressLayer.path = bezierPath.cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(self.progressLayer)
    }
    
    func animateCurveToProgress(progress: Float) {
        
        if progressLayer == nil {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = NSNumber(value: Float(progressLayer.strokeEnd))
        animation.toValue = NSNumber(value: progress)
        animation.duration = 0.05
        animation.fillMode = CAMediaTimingFillMode.forwards
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "strokeEnd")
    }
    
}
