//
//  PhotoSliderView.swift
//  PhotoSlider
//

import SwiftUI

/// 複数枚の写真をフルスクリーンでページングして表示する SwiftUI ビュー。
///
/// 横スワイプでページ遷移、縦スワイプでフルスクリーンを閉じる、ピンチ／ダブルタップでズーム、
/// という操作は v1.5.0 (UIKit) とまったく同じ操作感です（内部で実績ある `UIScrollView`
/// エンジンを再利用しています）。
///
/// 自前の `.fullScreenCover` / `.sheet` の中に直接置くか、
/// ``SwiftUICore/View/photoSlider(isPresented:photos:selection:configuration:imageLoader:)``
/// modifier を使って表示してください。
///
/// ```swift
/// .photoSlider(isPresented: $isPresented, photos: photos, selection: $index)
/// ```
@MainActor
public struct PhotoSliderView: View {

    private let photos: [PhotoItem]
    @Binding private var selection: Int
    private let configuration: PhotoSliderConfiguration
    private let imageLoader: any ImageLoader

    @Environment(\.dismiss) private var dismiss
    @Environment(\.photoSliderCallbacks) private var callbacks

    /// PhotoSlider を構築します。
    ///
    /// - Parameters:
    ///   - photos: 表示する写真の配列。空配列でも初期化は成功しますが、ビューは空表示になります。
    ///   - selection: 現在表示中のページインデックス。範囲外の値は最も近い有効インデックスに丸められます。
    ///   - configuration: 見た目と挙動のオプション。省略時は ``PhotoSliderConfiguration/default``。
    ///   - imageLoader: 画像取得を行うローダー。省略時は ``ImageLoader/default``（`URLSession` ベース）。
    public init(
        photos: [PhotoItem],
        selection: Binding<Int>,
        configuration: PhotoSliderConfiguration = .default,
        imageLoader: any ImageLoader = .default
    ) {
        self.photos = photos
        self._selection = selection
        self.configuration = configuration
        self.imageLoader = imageLoader
    }

    public var body: some View {
        PhotoSliderControllerRepresentable(
            items: photos,
            selection: $selection,
            configuration: configuration,
            imageLoader: imageLoader,
            callbacks: callbacks,
            onRequestDismiss: { dismiss() }
        )
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
}

#if DEBUG
private struct PhotoSliderPreviewHost: View {
    @State private var selection = 0

    private let photos: [PhotoItem] = {
        let colors: [UIColor] = [.systemIndigo, .systemTeal, .systemPink]
        return colors.enumerated().map { index, color in
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 1600))
            let image = renderer.image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 1200, height: 1600))
            }
            return PhotoItem(source: .uiImage(image), caption: "Sample \(index + 1)")
        }
    }()

    var body: some View {
        PhotoSliderView(photos: photos, selection: $selection)
    }
}

#Preview {
    PhotoSliderPreviewHost()
}
#endif
