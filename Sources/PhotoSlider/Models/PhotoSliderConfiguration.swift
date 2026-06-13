//
//  PhotoSliderConfiguration.swift
//  PhotoSlider
//

import SwiftUI

/// PhotoSlider の見た目・挙動の構成オプション。
///
/// すべて値型のフィールドで、`var` で個別に書き換え可能です。
/// デフォルトは v1.5.0 のフルスクリーンビューアと同じ操作感になるよう調整されています。
public struct PhotoSliderConfiguration: Sendable, Equatable {

    /// 背景色。デフォルト `.black`。
    public var backgroundColor: Color

    /// ページインジケータ（ドット）を表示するか。デフォルト `true`。
    public var showsPageIndicator: Bool

    /// 閉じるボタンを表示するか。デフォルト `true`。
    public var showsCloseButton: Bool

    /// 共有ボタンを表示するか。デフォルト `false`。
    ///
    /// タップ時は ``PhotoSliderCallbacks/onShare`` が発火します（ライブラリは独自に共有シートを出しません）。
    public var showsShareButton: Bool

    /// キャプションを表示するか。デフォルト `true`。
    /// `PhotoItem.caption` が `nil` の場合は当該ページでキャプションを表示しません。
    public var showsCaption: Bool

    /// 縦スワイプでフルスクリーンを閉じる挙動を有効にするか。デフォルト `true`。
    public var enableSwipeToDismiss: Bool

    /// ピンチによるズームを有効にするか。デフォルト `true`。
    public var enablePinchToZoom: Bool

    /// ズーム最大倍率。デフォルト `3.0`。
    public var maxZoomScale: CGFloat

    /// 縦スワイプ距離が画面高さの何割を超えたら閉じるか（0.0...1.0）。デフォルト `0.4`。
    ///
    /// v1.5.0 と同じ「画面高さの 40%」を初期値としています。
    /// この距離に満たなくても、十分な速度でフリックすれば閉じます（速度しきい値は内部固定）。
    public var dismissProgressThreshold: CGFloat

    /// すべてのパラメータを明示して初期化します。引数順は宣言順と一致します。
    public init(
        backgroundColor: Color = .black,
        showsPageIndicator: Bool = true,
        showsCloseButton: Bool = true,
        showsShareButton: Bool = false,
        showsCaption: Bool = true,
        enableSwipeToDismiss: Bool = true,
        enablePinchToZoom: Bool = true,
        maxZoomScale: CGFloat = 3.0,
        dismissProgressThreshold: CGFloat = 0.4
    ) {
        self.backgroundColor = backgroundColor
        self.showsPageIndicator = showsPageIndicator
        self.showsCloseButton = showsCloseButton
        self.showsShareButton = showsShareButton
        self.showsCaption = showsCaption
        self.enableSwipeToDismiss = enableSwipeToDismiss
        self.enablePinchToZoom = enablePinchToZoom
        self.maxZoomScale = maxZoomScale
        self.dismissProgressThreshold = dismissProgressThreshold
    }

    /// デフォルト構成。
    public static var `default`: PhotoSliderConfiguration { .init() }
}
