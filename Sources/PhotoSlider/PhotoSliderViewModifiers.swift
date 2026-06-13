//
//  PhotoSliderViewModifiers.swift
//  PhotoSlider
//

import SwiftUI

// MARK: - Presentation

private struct PhotoSliderPresentationModifier: ViewModifier {

    @Binding var isPresented: Bool
    let photos: [PhotoItem]
    @Binding var selection: Int
    let configuration: PhotoSliderConfiguration
    let imageLoader: any ImageLoader

    @Environment(\.photoSliderCallbacks) private var callbacks

    func body(content: Content) -> some View {
        content.fullScreenCover(isPresented: $isPresented) {
            PhotoSliderView(
                photos: photos,
                selection: $selection,
                configuration: configuration,
                imageLoader: imageLoader
            )
            // Re-inject the callbacks so they cross the presentation boundary.
            .environment(\.photoSliderCallbacks, callbacks)
        }
    }
}

public extension View {

    /// `isPresented` が `true` の間 PhotoSlider をフルスクリーンカバーで表示します。
    ///
    /// このビューに付与した ``photoSliderCallbacks(_:)`` や個別コールバック modifier は、
    /// カバー内の PhotoSlider にそのまま引き継がれます（この modifier より前に付けてください）。
    ///
    /// - Parameters:
    ///   - isPresented: 表示状態を制御する Binding。
    ///   - photos: 表示する写真の配列。
    ///   - selection: 現在ページの Binding。
    ///   - configuration: 構成オプション。省略時は ``PhotoSliderConfiguration/default``。
    ///   - imageLoader: 画像ローダー。省略時は ``ImageLoader/default``。
    func photoSlider(
        isPresented: Binding<Bool>,
        photos: [PhotoItem],
        selection: Binding<Int>,
        configuration: PhotoSliderConfiguration = .default,
        imageLoader: any ImageLoader = .default
    ) -> some View {
        modifier(
            PhotoSliderPresentationModifier(
                isPresented: isPresented,
                photos: photos,
                selection: selection,
                configuration: configuration,
                imageLoader: imageLoader
            )
        )
    }
}

// MARK: - Callbacks

public extension View {

    /// PhotoSlider のイベント群を一括で購読します。
    ///
    /// 同一ビューツリー内で複数回呼び出した場合は後勝ち（上書き）です。
    func photoSliderCallbacks(_ callbacks: PhotoSliderCallbacks) -> some View {
        environment(\.photoSliderCallbacks, callbacks)
    }

    /// ページが変更されたときに呼び出されるクロージャを登録します。
    func onPhotoSliderPageChanged(
        _ action: @escaping @MainActor @Sendable (Int) -> Void
    ) -> some View {
        transformEnvironment(\.photoSliderCallbacks) { $0.onPageChanged = action }
    }

    /// dismiss 直前に呼び出されるクロージャを登録します。
    func onPhotoSliderWillDismiss(
        _ action: @escaping @MainActor @Sendable () -> Void
    ) -> some View {
        transformEnvironment(\.photoSliderCallbacks) { $0.onWillDismiss = action }
    }

    /// dismiss 完了後に呼び出されるクロージャを登録します。
    func onPhotoSliderDidDismiss(
        _ action: @escaping @MainActor @Sendable () -> Void
    ) -> some View {
        transformEnvironment(\.photoSliderCallbacks) { $0.onDidDismiss = action }
    }

    /// 共有ボタンタップ時に呼び出されるクロージャを登録します。
    func onPhotoSliderShare(
        _ action: @escaping @MainActor @Sendable (PhotoItem) -> Void
    ) -> some View {
        transformEnvironment(\.photoSliderCallbacks) { $0.onShare = action }
    }

    /// 削除要求時に呼び出される async クロージャを登録します。`true` 返却で削除確定扱いです。
    func onPhotoSliderRequestDelete(
        _ action: @escaping @MainActor @Sendable (PhotoItem) async -> Bool
    ) -> some View {
        transformEnvironment(\.photoSliderCallbacks) { $0.onRequestDelete = action }
    }
}
