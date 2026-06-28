//
//  PhotoSliderConfiguration.swift
//  PhotoSlider
//

import SwiftUI

/// Configuration options for PhotoSlider's appearance and behavior.
///
/// All fields are value types and can be modified individually via `var`.
/// Defaults are tuned to match the feel of the v1.5.0 full-screen viewer.
public struct PhotoSliderConfiguration: Sendable, Equatable {

    /// Background color. Defaults to `.black`.
    public var backgroundColor: Color

    /// Whether to show the page indicator (dots). Defaults to `true`.
    public var showsPageIndicator: Bool

    /// Whether to show the close button. Defaults to `true`.
    public var showsCloseButton: Bool

    /// Whether to show the share button. Defaults to `false`.
    ///
    /// Tapping it presents the default system share sheet (see
    /// ``PhotoSliderConfiguration/usesBuiltInShareSheet``) and also fires
    /// ``PhotoSliderCallbacks/onShare``.
    public var showsShareButton: Bool

    /// Whether to show captions. Defaults to `true`.
    /// When `PhotoItem.caption` is `nil`, no caption is shown for that page.
    public var showsCaption: Bool

    /// Whether to enable swipe-down to dismiss the full-screen view. Defaults to `true`.
    public var enableSwipeToDismiss: Bool

    /// Whether to enable pinch-to-zoom. Defaults to `true`.
    public var enablePinchToZoom: Bool

    /// Maximum zoom scale. Defaults to `3.0`.
    public var maxZoomScale: CGFloat

    /// Fraction of the screen height a vertical swipe must exceed to dismiss (0.0...1.0). Defaults to `0.4`.
    ///
    /// The initial value matches v1.5.0's "40% of screen height".
    /// Even below this distance, a fast enough flick still dismisses (the velocity threshold is fixed internally).
    public var dismissProgressThreshold: CGFloat

    /// Whether to present the built-in system share sheet when the share button is tapped. Defaults to `true`.
    ///
    /// When `true` (default), tapping the share button presents the system share sheet
    /// (`UIActivityViewController`) for the current image. When `false`, no built-in sheet is shown
    /// and you handle sharing yourself via ``PhotoSliderCallbacks/onShare``.
    public var usesBuiltInShareSheet: Bool

    /// Initializes with all parameters explicitly. Parameter order matches declaration order.
    public init(
        backgroundColor: Color = .black,
        showsPageIndicator: Bool = true,
        showsCloseButton: Bool = true,
        showsShareButton: Bool = false,
        showsCaption: Bool = true,
        enableSwipeToDismiss: Bool = true,
        enablePinchToZoom: Bool = true,
        maxZoomScale: CGFloat = 3.0,
        dismissProgressThreshold: CGFloat = 0.4,
        usesBuiltInShareSheet: Bool = true
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
        self.usesBuiltInShareSheet = usesBuiltInShareSheet
    }

    /// The default configuration.
    public static var `default`: PhotoSliderConfiguration { .init() }
}
