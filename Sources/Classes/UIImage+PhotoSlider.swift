//
//  UIImage+PhotoSlider.swift
//  PhotoSlider
//
//  Created by nakajijapan on 2016/09/29.
//  Copyright © 2016 nakajijapan. All rights reserved.
//
import Foundation

extension UIView {

    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: 0.0)
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
