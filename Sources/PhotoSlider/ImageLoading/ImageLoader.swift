//
//  ImageLoader.swift
//  PhotoSlider
//

import Foundation

/// 画像取得を差し替え可能にするプロトコル。
///
/// デフォルト実装として ``DefaultImageLoader``（`URLSession` ベース、Kingfisher 非依存）を提供します。
/// Kingfisher を使いたい場合は別ターゲット `PhotoSliderKingfisher` の `KingfisherImageLoader` を利用してください。
///
/// ```swift
/// PhotoSliderView(photos: photos, selection: $index, imageLoader: .default)
/// ```
public protocol ImageLoader: Sendable {

    /// 指定 URL から画像を読み込みます。
    ///
    /// - Parameter url: 取得対象の URL。
    /// - Returns: 読み込み済みの ``PlatformImage``。
    /// - Throws: 取得・デコードに失敗した場合のエラー。
    func loadImage(from url: URL) async throws -> PlatformImage

    /// 進捗付きで画像を読み込みます。
    ///
    /// デフォルト実装は `onProgress` を無視して ``loadImage(from:)`` に委譲します。
    /// 進捗を提供したい実装はこのメソッドをオーバーライドしてください。
    ///
    /// - Parameters:
    ///   - url: 取得対象の URL。
    ///   - onProgress: 0.0...1.0 の進捗値で（メインアクター上で）呼び出されるクロージャ。
    /// - Returns: 読み込み済みの ``PlatformImage``。
    func loadImage(
        from url: URL,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void
    ) async throws -> PlatformImage
}

public extension ImageLoader {

    /// `onProgress` を無視して ``loadImage(from:)`` に委譲するデフォルト実装。
    func loadImage(
        from url: URL,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void
    ) async throws -> PlatformImage {
        try await loadImage(from: url)
    }
}
