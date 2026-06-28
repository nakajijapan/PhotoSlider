//
//  PlatformImage.swift
//  PhotoSlider
//

import UIKit

/// A cross-platform image type. On iOS it is an alias for `UIImage`.
///
/// It exists as a substitution point for a future macOS / tvOS expansion,
/// but PhotoSlider 2.0 is iOS-only.
public typealias PlatformImage = UIImage
