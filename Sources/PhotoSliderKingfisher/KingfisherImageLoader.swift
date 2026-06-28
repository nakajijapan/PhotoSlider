//
//  KingfisherImageLoader.swift
//  PhotoSliderKingfisher
//

import Foundation
import Kingfisher
import PhotoSlider

/// An ``ImageLoader`` implementation that uses Kingfisher.
///
/// `PhotoSlider` itself has no Kingfisher dependency. Only when you use this loader,
/// add the `PhotoSliderKingfisher` product and `import Kingfisher` separately.
///
/// ```swift
/// import PhotoSlider
/// import PhotoSliderKingfisher
///
/// PhotoSliderView(photos: photos, selection: $index, imageLoader: .kingfisher())
/// ```
public struct KingfisherImageLoader: ImageLoader {

    private let options: KingfisherOptionsInfo

    /// - Parameter options: The options to pass to Kingfisher.
    public init(options: KingfisherOptionsInfo = []) {
        self.options = options
    }

    public func loadImage(from url: URL) async throws -> PlatformImage {
        try await retrieve(url: url, onProgress: nil)
    }

    public func loadImage(
        from url: URL,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void
    ) async throws -> PlatformImage {
        try await retrieve(url: url, onProgress: onProgress)
    }

    private func retrieve(
        url: URL,
        onProgress: (@MainActor @Sendable (Double) -> Void)?
    ) async throws -> PlatformImage {
        try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: options,
                progressBlock: { received, total in
                    guard let onProgress, total > 0 else { return }
                    let progress = Double(received) / Double(total)
                    Task { @MainActor in onProgress(progress) }
                },
                completionHandler: { result in
                    switch result {
                    case .success(let value):
                        continuation.resume(returning: value.image)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
}
