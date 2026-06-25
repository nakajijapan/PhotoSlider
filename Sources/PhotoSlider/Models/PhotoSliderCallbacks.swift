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

    /// ヒーロー(ズーム)遷移に伴い、呼び出し側の元サムネイルの可視状態を切り替えるべきタイミングで呼ばれます。
    ///
    /// ヒーロー遷移中はタップしたサムネイル位置から全画面へ画像が移動するため、呼び出し側の元サムネを
    /// 隠さないと移動中のヒーロー画像と重なって**二重表示**になります。このコールバックはその「隠す/戻す」
    /// タイミングだけを通知し、実際の可視切替え（`opacity` または `isHidden`）は呼び出し側の責務です。
    ///
    /// - 第 1 引数 `index`: 対象サムネイルの index。
    ///   - `isHidden == true`（隠す）のとき: 提示したヒーロー対象ページ（present のフレーム解決に使った `selection`）。
    ///   - `isHidden == false`（戻す）のとき: present 時に隠した index（= 隠す通知で渡したのと同じ値）。
    ///     ビューア内で別ページにスワイプして閉じても、最初に隠したサムネが必ず再表示されるようこの値を渡します。
    /// - 第 2 引数 `isHidden`: `true` のとき隠す（present のズーム完了後＝画像が中央へ拡大し切って遷移が完了した時点で 1 回）、
    ///   `false` のとき再表示する（dismiss 完了後＝縮小アニメが戻り切った後に 1 回）。
    ///   このタイミングではビューアが完全に画面を覆っているため、隠す前にちらつきは見えません。
    ///   縦スワイプ閉じでも dismiss 完了後に必ず `false` が通知されます。
    ///
    /// 呼び出し側はこの index のサムネの `opacity`（または `isHidden`）をこの値に従って切り替えてください。
    /// `sourceFrame` 無しのクロスフェード提示や、`sourceFrame` が nil でフェードへフォールバックした提示では
    /// **呼ばれません**（その場合は二重表示が起きないため隠す必要がありません）。
    ///
    /// 個別 modifier ``SwiftUICore/View/onPhotoSliderSourceVisibilityChange(_:)`` でも登録できます。
    /// 発火するのは ``SwiftUICore/View/photoSlider(isPresented:photos:selection:configuration:imageLoader:sourceFrame:)``
    /// のヒーロー提示パスのみです。
    public var onSourceVisibilityChange: (@MainActor @Sendable (_ index: Int, _ isHidden: Bool) -> Void)?

    /// 全フィールドを `nil` で初期化します。
    public init(
        onWillDismiss: (@MainActor @Sendable () -> Void)? = nil,
        onDidDismiss: (@MainActor @Sendable () -> Void)? = nil,
        onPageChanged: (@MainActor @Sendable (Int) -> Void)? = nil,
        onShare: (@MainActor @Sendable (PhotoItem) -> Void)? = nil,
        onRequestDelete: (@MainActor @Sendable (PhotoItem) async -> Bool)? = nil,
        onSourceVisibilityChange: (@MainActor @Sendable (_ index: Int, _ isHidden: Bool) -> Void)? = nil
    ) {
        self.onWillDismiss = onWillDismiss
        self.onDidDismiss = onDidDismiss
        self.onPageChanged = onPageChanged
        self.onShare = onShare
        self.onRequestDelete = onRequestDelete
        self.onSourceVisibilityChange = onSourceVisibilityChange
    }
}
