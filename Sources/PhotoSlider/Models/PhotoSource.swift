//
//  PhotoSource.swift
//  PhotoSlider
//

import UIKit

/// 1 枚の写真のソース種別。
///
/// PhotoSlider はこの値を見て、`ImageLoader` 経由で取得するか、
/// メモリ上の画像をそのまま表示するかを切り替えます。
public enum PhotoSource: Hashable, Sendable {

    /// リモート URL。``ImageLoader`` 経由で非同期に取得します。
    case remote(URL)

    /// すでにメモリ上にある `UIImage`。同期的に表示されます。
    case uiImage(UIImage)

    /// メモリ上のバイナリデータ。`UIImage(data:)` でデコードして表示します。
    case data(Data)
}
