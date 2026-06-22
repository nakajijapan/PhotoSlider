//
//  PhotoSliderHeroResolver.swift
//  PhotoSlider
//
//  Pure coordinate-resolution and fallback logic for the hero (thumbnail <-> fullscreen)
//  zoom transition. Deliberately UI-free so the boundary cases (nil / empty / off-screen
//  source frame -> fade fallback) can be unit-tested without booting a UI host.
//

import CoreGraphics

enum PhotoSliderHeroResolver {

    /// Resolves the caller-supplied `.global` (SwiftUI global = window-local point) source
    /// frame into a window-space frame suitable for the hero `containerView`, deciding along
    /// the way whether the hero transition is even applicable.
    ///
    /// Returns `nil` (meaning: fall back to a plain cross-dissolve) when the frame is:
    /// - `nil` (the caller has no thumbnail for this index),
    /// - empty / non-positive (`width <= 0` or `height <= 0`),
    /// - completely off-screen (does not intersect `windowBounds`).
    ///
    /// Otherwise returns the frame to animate from/to. Because SwiftUI's `.global` space and
    /// an `.overFullScreen` `transitionContext.containerView` share the same window-local
    /// point coordinate system, the value is passed through unchanged. Multi-window / split
    /// view differences are absorbed by the caller via `window.convert(_:from:)` before the
    /// frame ever reaches `windowBounds` here; this function is the single place that decides
    /// applicability so the decision stays testable.
    static func resolvedWindowFrame(global: CGRect?, in windowBounds: CGRect) -> CGRect? {
        guard let global else { return nil }
        guard isUsable(global) else { return nil }
        guard global.intersects(windowBounds) else { return nil }
        return global
    }

    /// Whether the hero transition should be attempted at all for the given source frame.
    ///
    /// Mirrors ``resolvedWindowFrame(global:in:)`` but exposed as a boolean so the
    /// presentation bridge can decide "wire the transitioning delegate" vs "fall back to
    /// fade" without re-deriving the rule.
    static func shouldUseHero(global: CGRect?, in windowBounds: CGRect) -> Bool {
        resolvedWindowFrame(global: global, in: windowBounds) != nil
    }

    private static func isUsable(_ rect: CGRect) -> Bool {
        guard !rect.isEmpty else { return false }
        // Use the raw `size` (not `rect.width`/`rect.height`, which normalise a negative size
        // to its absolute value) so a negative-dimension rect is rejected as unusable.
        guard rect.size.width > 0, rect.size.height > 0 else { return false }
        guard rect.origin.x.isFinite, rect.origin.y.isFinite else { return false }
        guard rect.size.width.isFinite, rect.size.height.isFinite else { return false }
        return true
    }
}
