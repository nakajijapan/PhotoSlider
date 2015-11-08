//
//  Photo.swift
//  Pods
//
//  Created by nakajijapan on 2015/11/08.
//
//

import UIKit

public class Photo: NSObject {
    
    public var imageURL: NSURL?
    public var image: UIImage?
    public var caption = ""
    
    public init(imageURL: NSURL) {
        super.init()
        self.imageURL = imageURL
    }
    
    public init(image: UIImage) {
        super.init()
        self.image = image
    }
    
    public init(imageURL: NSURL, caption: String) {
        super.init()
        self.imageURL = imageURL
        self.caption = caption
    }
    
    public init(image: UIImage, caption: String) {
        super.init()
        self.image = image
        self.caption = caption
    }

    
}
