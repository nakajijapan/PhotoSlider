//
//  CollectionViewCell.swift
//
//  Created by nakajijapan on 3/29/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

public class CollectionViewCell: UICollectionViewCell {

    var imageView: PhotoSlider.ImageView!
    var progressView: PhotoSlider.ProgressView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initilize()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initilize()
    }
    
    func initilize() {
        self.imageView = PhotoSlider.ImageView(frame: self.bounds)
        self.addSubview(self.imageView)
        
        self.progressView = ProgressView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        self.progressView.center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        self.progressView.hidden = true
        self.addSubview(self.progressView)
    }
    
    public func loadImage(imageURL: NSURL) {
        self.progressView.hidden = false
        self.imageView.imageView.sd_setImageWithURL(
            imageURL,
            placeholderImage: nil,
            options: .CacheMemoryOnly,
            progress: { (receivedSize, expectedSize) -> Void in
                let progress = Float(receivedSize) / Float(expectedSize)
                println("progress = \(progress)")
                self.progressView.animateCurveToProgress(progress)
        }) { (image, error, cacheType, ImageView) -> Void in
            self.progressView.hidden = true
        }
    }

}
