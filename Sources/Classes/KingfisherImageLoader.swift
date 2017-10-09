//
//  KingfisherImageLoader.swift
//  PhotoSlider
//
//  Created by ChangHoon Jung on 2017. 1. 10..
//  Copyright © 2017년 nakajijapan. All rights reserved.
//

import Foundation
import Kingfisher

public class KingfisherImageLoader: ImageLoader {
    public func load(
        imageView: UIImageView?,
        fromURL url: URL?,
        progress: @escaping ImageLoader.ProgressBlock,
        completion: @escaping ImageLoader.CompletionBlock) {
        imageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: [.transition(.fade(1))],
            progressBlock: { (receivedSize, totalSize) in
                progress(
                    Int(truncatingIfNeeded: receivedSize),
                    Int(truncatingIfNeeded: totalSize)
                )
            },
            completionHandler: { (image, error, _, _) in
                if let image = image, error == nil {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        )
    }
}
