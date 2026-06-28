//
//  PhotoSliderCallbacksEnvironment.swift
//  PhotoSlider
//

import SwiftUI

private struct PhotoSliderCallbacksKey: EnvironmentKey {
    static let defaultValue = PhotoSliderCallbacks()
}

extension EnvironmentValues {
    /// PhotoSlider's event callbacks. Set via `.photoSliderCallbacks(_:)` or the individual modifiers.
    var photoSliderCallbacks: PhotoSliderCallbacks {
        get { self[PhotoSliderCallbacksKey.self] }
        set { self[PhotoSliderCallbacksKey.self] = newValue }
    }
}
