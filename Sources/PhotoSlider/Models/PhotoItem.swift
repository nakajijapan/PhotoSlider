//
//  PhotoItem.swift
//  PhotoSlider
//

import Foundation

/// PhotoSlider が表示する 1 枚の写真を表す不変モデル。
///
/// `id` は `init` 時に新規発行される `UUID` です。同じ画像でも別インスタンスは別 ID を持ちます。
/// 並び替えや差分更新で同一性を保ちたい場合は、生成した `PhotoItem` を呼び出し側で保持してください。
///
/// ```swift
/// let photos: [PhotoItem] = [
///     .init(source: .remote(url), caption: "Aurora"),
///     .init(source: .uiImage(localImage)),
/// ]
/// ```
public struct PhotoItem: Identifiable, Hashable, Sendable {

    /// 一意な識別子。`init` 時に自動採番されます。
    public let id: UUID

    /// 画像のソース。
    public var source: PhotoSource

    /// 画像下部に表示するキャプション。`nil` の場合は当該ページでキャプションを表示しません。
    public var caption: String?

    /// 写真を生成します。
    ///
    /// - Parameters:
    ///   - source: 画像のソース。
    ///   - caption: 画像下部に表示するキャプション。省略時は `nil`（非表示）。
    public init(source: PhotoSource, caption: String? = nil) {
        self.id = UUID()
        self.source = source
        self.caption = caption
    }
}
