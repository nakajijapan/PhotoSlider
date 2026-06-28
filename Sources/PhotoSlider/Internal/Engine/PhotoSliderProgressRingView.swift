//
//  PhotoSliderProgressRingView.swift
//  PhotoSlider
//
//  Ported verbatim from v1.5.0 `ProgressView` to preserve the exact loading ring visual.
//

import UIKit

final class PhotoSliderProgressRingView: UIView {

    private var progressLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        createInitialProgressLayer()
        createProgressLayer()
    }

    private func createInitialProgressLayer() {
        let startAngle = -Double.pi / 2.0
        let endAngle = Double.pi + 1.5
        let centerPoint = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)

        let initialLayer = CAShapeLayer()
        initialLayer.path = UIBezierPath(
            arcCenter: centerPoint,
            radius: 20.0,
            startAngle: CGFloat(startAngle),
            endAngle: CGFloat(endAngle),
            clockwise: true
        ).cgPath
        initialLayer.backgroundColor = UIColor.clear.cgColor
        initialLayer.fillColor = UIColor.clear.cgColor
        initialLayer.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2).cgColor
        initialLayer.lineWidth = 4.0
        initialLayer.strokeStart = 0.0
        initialLayer.strokeEnd = 1.0
        layer.addSublayer(initialLayer)
    }

    private func createProgressLayer() {
        let startAngle = -Double.pi / 2.0
        let endAngle = Double.pi + 1.5
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)

        progressLayer = CAShapeLayer()
        let bezierPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: 20.0,
            startAngle: CGFloat(startAngle),
            endAngle: CGFloat(endAngle),
            clockwise: true
        )
        progressLayer.path = bezierPath.cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(progressLayer)
    }

    func animateCurveToProgress(progress: Float) {
        guard let progressLayer else { return }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = NSNumber(value: Float(progressLayer.strokeEnd))
        animation.toValue = NSNumber(value: progress)
        animation.duration = 0.05
        animation.fillMode = CAMediaTimingFillMode.forwards
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "strokeEnd")
    }
}
