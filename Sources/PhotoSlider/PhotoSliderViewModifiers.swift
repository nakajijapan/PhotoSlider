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
    /// 提示・解除はクロスフェードで行われます。サムネイル ⇄ 全画面のヒーロー(ズーム)遷移が
    /// 必要な場合は、`sourceFrame` 付きの
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:sourceFrame:)``
    /// を使ってください。
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

    /// `isPresented` が `true` の間 PhotoSlider をフルスクリーン表示し、
    /// サムネイル ⇄ 全画面のヒーロー(ズーム)遷移で提示・解除します。
    ///
    /// `sourceFrame` は「指定 index のサムネイルが**画面座標 (`.global`)** で占める矩形」を返すクロージャです。
    /// SwiftUI 側では `GeometryReader { proxy in ... proxy.frame(in: .global) }` で取得した値を渡してください。
    ///
    /// - 提示時: 現在ページ (`selection`) の `sourceFrame` から全画面へ画像が拡大移動します。
    /// - 解除時: その時点の現在ページ (`selection`) の `sourceFrame` へ画像が縮小移動して戻ります
    ///   （ビューア内で別ページにスワイプ済みなら、戻り先もそのページのサムネ位置になります）。
    ///
    /// `sourceFrame(index)` が `nil`・空矩形・画面外の矩形を返した場合、その提示/解除は
    /// 従来のクロスフェード提示にフォールバックします（クラッシュしません）。
    /// ヒーロー遷移が不要な場合は、`sourceFrame` 引数を持たない
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:)`` を使ってください。
    ///
    /// このビューに付与した ``photoSliderCallbacks(_:)`` や個別コールバック modifier は、
    /// ヒーロー提示パスにもそのまま引き継がれます（この modifier より前に付けてください）。
    ///
    /// ## 使用例
    ///
    /// 各サムネイルが画面座標 (`.global`) で占めるフレームを記録し、それを `sourceFrame` から返します。
    ///
    /// ```swift
    /// struct CarouselScreen: View {
    ///     let photos: [PhotoItem]
    ///     @State private var selection = 0
    ///     @State private var isPresented = false
    ///     // 各 index のサムネが画面座標で占めるフレームを記録する。
    ///     @State private var frames: [Int: CGRect] = [:]
    ///
    ///     var body: some View {
    ///         TabView(selection: $selection) {
    ///             ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
    ///                 Button { isPresented = true } label: {
    ///                     thumbnail(for: photo)
    ///                 }
    ///                 .background(
    ///                     GeometryReader { proxy in
    ///                         Color.clear
    ///                             .onAppear { frames[index] = proxy.frame(in: .global) }
    ///                             .onChange(of: proxy.frame(in: .global)) { _, new in
    ///                                 frames[index] = new
    ///                             }
    ///                     }
    ///                 )
    ///                 .tag(index)
    ///             }
    ///         }
    ///         .tabViewStyle(.page)
    ///         .photoSlider(
    ///             isPresented: $isPresented,
    ///             photos: photos,
    ///             selection: $selection,
    ///             sourceFrame: { index in frames[index] } // nil を返せばフェードにフォールバック
    ///         )
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: 表示状態を制御する Binding。
    ///   - photos: 表示する写真の配列。
    ///   - selection: 現在ページの Binding。提示・解除の両方でヒーロー対象ページの**真実源**になります。
    ///   - configuration: 構成オプション。省略時は ``PhotoSliderConfiguration/default``。
    ///   - imageLoader: 画像ローダー。省略時は ``ImageLoader/default``。
    ///   - sourceFrame: index → サムネイルの画面座標フレーム（`CGRect?`）を返す provider。
    ///     `.global` 座標空間で返してください。
    func photoSlider(
        isPresented: Binding<Bool>,
        photos: [PhotoItem],
        selection: Binding<Int>,
        configuration: PhotoSliderConfiguration = .default,
        imageLoader: any ImageLoader = .default,
        sourceFrame: @escaping (Int) -> CGRect?
    ) -> some View {
        modifier(
            PhotoSliderHeroPresentationModifier(
                isPresented: isPresented,
                photos: photos,
                selection: selection,
                configuration: configuration,
                imageLoader: imageLoader,
                sourceFrame: sourceFrame
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
