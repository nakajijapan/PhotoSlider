//
//  PlatformImage.swift
//  PhotoSlider
//

import UIKit

/// プラットフォーム共通の画像型。iOS では `UIImage` のエイリアスです。
///
/// 将来 macOS / tvOS へ展開する際の差し替え点として用意していますが、
/// PhotoSlider 2.0 は iOS 専用です。
public typealias PlatformImage = UIImage
