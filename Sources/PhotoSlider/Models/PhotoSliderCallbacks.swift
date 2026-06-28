//
//  PhotoSliderCallbacks.swift
//  PhotoSlider
//

import Foundation

/// A struct for subscribing to PhotoSlider events (the equivalent of the former `PhotoSliderDelegate`).
///
/// Inject it into the view tree via ``SwiftUICore/View/photoSliderCallbacks(_:)``, or register
/// individual callbacks with the per-event modifiers (such as ``SwiftUICore/View/onPhotoSliderPageChanged(_:)``).
public struct PhotoSliderCallbacks: Sendable {

    /// Called just before dismissal begins (before the slide-out animation).
    public var onWillDismiss: (@MainActor @Sendable () -> Void)?

    /// Called right after dismissal completes.
    public var onDidDismiss: (@MainActor @Sendable () -> Void)?

    /// Called with the new page index when the displayed page changes.
    public var onPageChanged: (@MainActor @Sendable (Int) -> Void)?

    /// Called with the corresponding ``PhotoItem`` when the share button is tapped.
    public var onShare: (@MainActor @Sendable (PhotoItem) -> Void)?

    /// Called when deletion is requested. Returning `true` indicates that the deletion is confirmed.
    ///
    /// PhotoSlider only sends the "user requested deletion" signal; it does not update the `photos`
    /// array itself. Updating the array is the caller's responsibility.
    public var onRequestDelete: (@MainActor @Sendable (PhotoItem) async -> Bool)?

    /// Called when the caller's source thumbnail should toggle its visibility during the hero (zoom) transition.
    ///
    /// During the hero transition the image moves from the tapped thumbnail's position to full screen,
    /// so unless the caller's source thumbnail is hidden, it overlaps the moving hero image and produces
    /// a **double image**. This callback only signals the timing to "hide / restore"; performing the actual
    /// visibility toggle (`opacity` or `isHidden`) is the caller's responsibility.
    ///
    /// - First argument `index`: The index of the target thumbnail.
    ///   - When `isHidden == true` (hide): The presented hero target page (the `selection` used to resolve the present frame).
    ///   - When `isHidden == false` (restore): The index hidden at present time (the same value passed in the hide notification).
    ///     This value is passed so that the originally hidden thumbnail is always restored, even if the viewer was closed after swiping to a different page.
    /// - Second argument `isHidden`: When `true`, hide (once, **before** the present zoom-in, i.e. at the start of presentation.
    ///   This way the hero image scales up from an empty thumbnail position from the start, preventing the source
    ///   thumbnail from peeking out beneath the hero image mid-scale and producing a double image).
    ///   When `false`, restore (once, after dismissal completes, i.e. after the shrink animation has fully returned).
    ///   `false` is always delivered after dismissal completes, even for a vertical-swipe close.
    ///
    /// The caller should toggle the `opacity` (or `isHidden`) of this index's thumbnail according to this value.
    /// It is **not called** for cross-fade presentation without `sourceFrame`, or for presentation that fell back
    /// to a fade because `sourceFrame` was nil (in those cases no double image occurs, so nothing needs to be hidden).
    ///
    /// It can also be registered via the individual modifier ``SwiftUICore/View/onPhotoSliderSourceVisibilityChange(_:)``.
    /// It fires only on the hero presentation path of
    /// ``SwiftUICore/View/photoSlider(isPresented:photos:selection:configuration:imageLoader:sourceFrame:)``.
    ///
    /// It is recommended to hide **synchronously yourself on tap** and rely only on the library's `isHidden: false`
    /// (restore) notification. `isHidden: true` arrives just before present (the tick after the tap), so relying on it
    /// to hide can cause a one-frame double image.
    public var onSourceVisibilityChange: (@MainActor @Sendable (_ index: Int, _ isHidden: Bool) -> Void)?

    /// Initializes every field to `nil`.
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

    /// `true` if every closure is `nil` (i.e. no callback is registered).
    var isEmpty: Bool {
        onWillDismiss == nil
            && onDidDismiss == nil
            && onPageChanged == nil
            && onShare == nil
            && onRequestDelete == nil
            && onSourceVisibilityChange == nil
    }
}
