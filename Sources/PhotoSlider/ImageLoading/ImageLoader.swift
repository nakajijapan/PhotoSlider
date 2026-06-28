//
//  ImageLoader.swift
//  PhotoSlider
//

import Foundation

/// A protocol that makes image fetching pluggable.
///
/// The default implementation is ``DefaultImageLoader`` (`URLSession`-based, with no Kingfisher dependency).
/// To use Kingfisher, use `KingfisherImageLoader` from the separate `PhotoSliderKingfisher` target.
///
/// ```swift
/// PhotoSliderView(photos: photos, selection: $index, imageLoader: .default)
/// ```
public protocol ImageLoader: Sendable {

    /// Loads an image from the given URL.
    ///
    /// - Parameter url: The URL to fetch.
    /// - Returns: The loaded ``PlatformImage``.
    /// - Throws: An error if fetching or decoding fails.
    func loadImage(from url: URL) async throws -> PlatformImage

    /// Loads an image with progress reporting.
    ///
    /// The default implementation ignores `onProgress` and delegates to ``loadImage(from:)``.
    /// Override this method in implementations that want to report progress.
    ///
    /// - Parameters:
    ///   - url: The URL to fetch.
    ///   - onProgress: A closure called (on the main actor) with a progress value in 0.0...1.0.
    /// - Returns: The loaded ``PlatformImage``.
    func loadImage(
        from url: URL,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void
    ) async throws -> PlatformImage
}

public extension ImageLoader {

    /// Default implementation that ignores `onProgress` and delegates to ``loadImage(from:)``.
    func loadImage(
        from url: URL,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void
    ) async throws -> PlatformImage {
        try await loadImage(from: url)
    }
}
