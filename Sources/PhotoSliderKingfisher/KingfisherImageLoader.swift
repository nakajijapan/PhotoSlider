//
//  KingfisherImageLoader.swift
//  PhotoSliderKingfisher
//

import Foundation
import Kingfisher
import PhotoSlider

/// Kingfisher を利用した ``ImageLoader`` 実装。
///
/// `PhotoSlider` 本体は Kingfisher に依存しません。このローダーを使うときだけ、
/// `PhotoSliderKingfisher` プロダクトを取り込み、`import Kingfisher` を別途行ってください。
///
/// ```swift
/// import PhotoSlider
/// import PhotoSliderKingfisher
///
/// PhotoSliderView(photos: photos, selection: $index, imageLoader: .kingfisher())
/// ```
public struct KingfisherImageLoader: ImageLoader {

    private let options: KingfisherOptionsInfo

    /// - Parameter options: Kingfisher へ渡すオプション群。
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
