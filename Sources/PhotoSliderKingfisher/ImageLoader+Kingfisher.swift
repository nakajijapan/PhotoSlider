//
//  ImageLoader+Kingfisher.swift
//  PhotoSliderKingfisher
//

import Kingfisher
import PhotoSlider

public extension ImageLoader where Self == KingfisherImageLoader {
    /// A factory for the Kingfisher-backed loader.
    ///
    /// ```swift
    /// PhotoSliderView(photos: photos, selection: $index, imageLoader: .kingfisher())
    /// ```
    /// - Parameter options: The options to pass to Kingfisher.
    static func kingfisher(options: KingfisherOptionsInfo = []) -> KingfisherImageLoader {
        KingfisherImageLoader(options: options)
    }
}
