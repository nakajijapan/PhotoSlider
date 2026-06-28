//
//  PhotoSource.swift
//  PhotoSlider
//

import UIKit

/// The source kind for a single photo.
///
/// PhotoSlider inspects this value to decide whether to fetch the image via
/// `ImageLoader` or to display an in-memory image directly.
public enum PhotoSource: Hashable, Sendable {

    /// A remote URL. Fetched asynchronously via ``ImageLoader``.
    case remote(URL)

    /// A `UIImage` already in memory. Displayed synchronously.
    case uiImage(UIImage)

    /// Binary data in memory. Decoded with `UIImage(data:)` for display.
    case data(Data)
}
