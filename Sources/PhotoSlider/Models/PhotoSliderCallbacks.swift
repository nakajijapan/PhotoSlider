//
//  PhotoSliderCallbacks.swift
//  PhotoSlider
//

import Foundation

/// PhotoSlider のイベント購読用構造体（旧 `PhotoSliderDelegate` 相当）。
///
/// ``SwiftUICore/View/photoSliderCallbacks(_:)`` 経由でビューツリーに注入するか、
/// 個別 modifier（``SwiftUICore/View/onPhotoSliderPageChanged(_:)`` など）を使って登録します。
public struct PhotoSliderCallbacks: Sendable {

    /// dismiss が始まる直前に呼ばれます（スライドアウトアニメーションの前）。
    public var onWillDismiss: (@MainActor @Sendable () -> Void)?

    /// dismiss が完了した直後に呼ばれます。
    public var onDidDismiss: (@MainActor @Sendable () -> Void)?

    /// 表示ページが変わったときに、新しいページインデックスとともに呼ばれます。
    public var onPageChanged: (@MainActor @Sendable (Int) -> Void)?

    /// 共有ボタンがタップされたときに、対象の ``PhotoItem`` とともに呼ばれます。
    public var onShare: (@MainActor @Sendable (PhotoItem) -> Void)?

    /// 削除が要求されたときに呼ばれます。戻り値 `true` で「削除を確定する」ことを表します。
    ///
    /// PhotoSlider 側は「ユーザーが削除を要求した」シグナルを送るだけで、`photos` 配列自体は更新しません。
    /// 実際の配列更新は呼び出し側の責務です。
    public var onRequestDelete: (@MainActor @Sendable (PhotoItem) async -> Bool)?

    /// 全フィールドを `nil` で初期化します。
    public init(
        onWillDismiss: (@MainActor @Sendable () -> Void)? = nil,
        onDidDismiss: (@MainActor @Sendable () -> Void)? = nil,
        onPageChanged: (@MainActor @Sendable (Int) -> Void)? = nil,
        onShare: (@MainActor @Sendable (PhotoItem) -> Void)? = nil,
        onRequestDelete: (@MainActor @Sendable (PhotoItem) async -> Bool)? = nil
    ) {
        self.onWillDismiss = onWillDismiss
        self.onDidDismiss = onDidDismiss
        self.onPageChanged = onPageChanged
        self.onShare = onShare
        self.onRequestDelete = onRequestDelete
    }
}
