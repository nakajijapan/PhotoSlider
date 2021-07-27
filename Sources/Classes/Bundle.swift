//
//  Bundle.swift
//  PhotoSlider
//
//  Created by Daichi Nakajima on 2021/07/27.
//  Copyright © 2021 nakajijapan. All rights reserved.
//

import class Foundation.Bundle

extension Foundation.Bundle {
    static var module: Bundle = {
        let bundleName = "PhotoSlider"

        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: PhotoSlider.ViewController.self).resourceURL,
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named PhotoSlider")
    }()
}
