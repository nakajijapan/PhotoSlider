//
//  CollectionViewCell.swift
//
//  Created by nakajijapan on 3/29/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

public class CollectionViewCell: UICollectionViewCell {

    var imageView: PhotoSlider.ImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = PhotoSlider.ImageView(frame: self.bounds)
        self.addSubview(self.imageView)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imageView = PhotoSlider.ImageView(frame: self.bounds)
        self.addSubview(self.imageView)
    }

}
