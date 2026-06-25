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
    /// カバー内の PhotoSlider にそのまま引き継がれます。これらは環境値として読み取られるため、
    /// **この modifier より後（=外側）に付けてください**（前＝内側に付けると提示パスへ伝播しません）。
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
    /// ヒーロー提示パスにもそのまま引き継がれます。これらは環境値として読み取られるため、
    /// **この modifier より後（=外側）に付けてください**（前＝内側に付けると提示パスへ伝播しません）。
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

    /// ヒーロー(ズーム)遷移中に、呼び出し側の元サムネイルの可視状態を切り替えるためのクロージャを登録します。
    ///
    /// ヒーロー遷移では、タップしたサムネイルの位置から全画面ビューアへ画像が拡大移動します。
    /// このとき呼び出し側の元サムネイル（カルーセルのページ画像など）は画面に残ったままなので、
    /// 移動中のヒーロー画像と重なって**二重表示**になります。この modifier はその「隠す/戻す」べき
    /// タイミングを通知し、実際の可視切替え（`opacity` 等）は呼び出し側に委ねます。
    ///
    /// - present のズーム完了後（画像が中央へ拡大し切って遷移が完了した時点）に `(index, isHidden: true)` が **1 回**呼ばれます。
    /// - dismiss 完了後（縮小アニメが戻り切った後）に `(index, isHidden: false)` が **1 回**呼ばれます。
    ///   この `index` は present 時に隠したのと**同じ index** です。ビューア内で別ページにスワイプして
    ///   閉じても、最初に隠したサムネが必ず再表示されます（隠れっぱなしになりません）。
    ///
    /// `sourceFrame` 付きの
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:sourceFrame:)``
    /// でヒーロー経路が成立したときのみ発火します。`sourceFrame` を持たない
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:)`` のクロスフェード提示や、
    /// `sourceFrame(index)` が `nil`・空矩形・画面外でフェードへフォールバックした提示では
    /// **呼ばれません**（ヒーロー画像が存在せず二重表示が起きないため）。
    ///
    /// 登録は任意（オプトイン）です。登録しなくても提示・解除の挙動は変わりません
    /// （その場合は遷移中の二重表示が残ります）。
    ///
    /// > Important: この modifier は `photoSlider(...)` より**後**に付けてください。
    /// > `transformEnvironment` で設定した環境値は「付与したビューの**子孫**」にしか流れません。
    /// > `photoSlider(...)` は内部に提示ホスト（環境値からこのコールバックを読む）を持つため、
    /// > この modifier を `photoSlider(...)` より**前**（=内側）に付けると提示ホストはコールバックを
    /// > 自身の**祖先**から読みに行き `nil` になります（コールバックが一度も発火しません）。
    /// > `photoSlider(...)` より**後**（=外側）に付けると提示ホストの祖先になり、正しく伝播します。
    ///
    /// ## 使用例
    ///
    /// 単一の `hiddenIndex` State を `isHidden ? index : nil` で切り替え、対象ページのサムネを透明にします。
    ///
    /// ```swift
    /// struct CarouselScreen: View {
    ///     let photos: [PhotoItem]
    ///     @State private var selection = 0
    ///     @State private var isPresented = false
    ///     @State private var frames: [Int: CGRect] = [:]
    ///     // ヒーロー遷移中に隠すページ index（隠す対象が無ければ nil）。
    ///     @State private var hiddenIndex: Int?
    ///
    ///     var body: some View {
    ///         TabView(selection: $selection) {
    ///             ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
    ///                 Button {
    ///                     // タップ即・同期でこのページを隠す（ズーム拡大の前に確実に消える）。
    ///                     hiddenIndex = index
    ///                     isPresented = true
    ///                 } label: {
    ///                     thumbnail(for: photo)
    ///                 }
    ///                 // 遷移中はこのページのサムネを透明にして二重表示を防ぐ。
    ///                 .opacity(hiddenIndex == index ? 0 : 1)
    ///                 .tag(index)
    ///             }
    ///         }
    ///         .tabViewStyle(.page)
    ///         .photoSlider(
    ///             isPresented: $isPresented,
    ///             photos: photos,
    ///             selection: $selection,
    ///             sourceFrame: { index in frames[index] }
    ///         )
    ///         // photoSlider(...) より後に付ける（提示ホストの祖先になり伝播する）。
    ///         .onPhotoSliderSourceVisibilityChange { _, isHidden in
    ///             // dismiss 完了: (index, false) で戻す（隠すのはタップ時に済ませてある）。
    ///             if !isHidden { hiddenIndex = nil }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter action: 可視状態を切り替えるクロージャ。第 1 引数は対象サムネイルの index、
    ///   第 2 引数 `isHidden` は `true` のとき隠す（present のズーム完了後）、`false` のとき再表示する（dismiss 完了後）。
    func onPhotoSliderSourceVisibilityChange(
        _ action: @escaping @MainActor @Sendable (_ index: Int, _ isHidden: Bool) -> Void
    ) -> some View {
        transformEnvironment(\.photoSliderCallbacks) { $0.onSourceVisibilityChange = action }
    }
}
