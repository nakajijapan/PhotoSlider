//
//  ImageLoader.swift
//  PhotoSlider
//
//  Created by ChangHoon Jung on 2017. 1. 10..
//  Copyright © 2017년 nakajijapan. All rights reserved.
//

import Foundation

public protocol ImageLoader: class {
    typealias ProgressBlock = (_ receivedSize: Int, _ totalSize: Int) -> Void
    typealias CompletionBlock = (_ image: UIImage?) -> Void

    func load(
        imageView: UIImageView?,
        fromURL url: URL?,
        progress: @escaping ImageLoader.ProgressBlock,
        completion: @escaping ImageLoader.CompletionBlock)
}
