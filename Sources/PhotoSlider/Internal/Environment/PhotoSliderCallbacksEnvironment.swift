//
//  PhotoSliderCallbacksEnvironment.swift
//  PhotoSlider
//

import SwiftUI

private struct PhotoSliderCallbacksKey: EnvironmentKey {
    static let defaultValue = PhotoSliderCallbacks()
}

extension EnvironmentValues {
    /// PhotoSlider のイベントコールバック群。`.photoSliderCallbacks(_:)` / 個別 modifier で設定します。
    var photoSliderCallbacks: PhotoSliderCallbacks {
        get { self[PhotoSliderCallbacksKey.self] }
        set { self[PhotoSliderCallbacksKey.self] = newValue }
    }
}
