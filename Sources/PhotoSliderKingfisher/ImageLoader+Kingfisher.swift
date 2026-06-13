//
//  ImageLoader+Kingfisher.swift
//  PhotoSliderKingfisher
//

import Kingfisher
import PhotoSlider

public extension ImageLoader where Self == KingfisherImageLoader {
    /// Kingfisher 連携ローダーのファクトリ。
    ///
    /// ```swift
    /// PhotoSliderView(photos: photos, selection: $index, imageLoader: .kingfisher())
    /// ```
    /// - Parameter options: Kingfisher へ渡すオプション群。
    static func kingfisher(options: KingfisherOptionsInfo = []) -> KingfisherImageLoader {
        KingfisherImageLoader(options: options)
    }
}
