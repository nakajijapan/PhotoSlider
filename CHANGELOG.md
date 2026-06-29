# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-06-29

PhotoSlider 2.0 is a SwiftUI-first rewrite ([#124](https://github.com/nakajijapan/PhotoSlider/pull/124)).
The proven `UIScrollView`-based interaction engine (paging, vertical swipe-to-dismiss
with linear background fade, pinch / tap-point double-tap zoom with momentum & bounce)
is reused internally and wrapped for SwiftUI, so the interaction feel stays byte-for-byte
identical to 1.5.0.

### Breaking Changes

- **Full SwiftUI rewrite.** The library now ships a SwiftUI-first API
  (`PhotoSliderView`, `.photoSlider(isPresented:...)`). The UIKit API
  (`PhotoSlider.ViewController`, `Photo`, `PhotoSliderDelegate`, …) has been removed —
  use 1.5.0 if you still need it.
- **Kingfisher is no longer a required dependency.** Image loading is abstracted behind
  the `ImageLoader` protocol (the default is a `URLSession`-based loader). Kingfisher is
  now available only as the optional `PhotoSliderKingfisher` product.
- **New minimum toolchain / platform:** Swift 6 with strict concurrency, Xcode 16+, and
  iOS 18+.
- **CocoaPods and Carthage support dropped.** Distribution is now Swift Package Manager
  only.

### Added

- Hero zoom transition: present and dismiss from a source frame via
  `.photoSlider(sourceFrame:)`.
- Source thumbnail is hidden during the hero zoom transition for a seamless hand-off.
- Share button that presents the system share sheet, with an SF Symbol icon.
- `usesBuiltInShareSheet` configuration to opt out of the built-in share sheet.
- DEBUG-time warning when callback modifiers are attached in the wrong order, plus
  documentation for the hide-on-tap pattern.

### Fixed

- PhotoSlider callbacks never fired unless the modifiers were attached after
  `.photoSlider`.
- A deferred hero present could permanently wedge the slider.
- `PhotoSliderView` is now opaque so it never flashes the host's background.
- White flash when closing the cross-fade (non-hero) PhotoSlider.
- Blur / black flash on swipe-to-dismiss during the hero transition.
- Source thumbnail is now hidden before the hero zoom starts.
- Source thumbnail is restored at the dismiss-zoom landing, removing a late gap.

### Documentation

- Translated all DocC and inline code comments to English.
- Corrected the `onPhotoSliderSourceVisibilityChange` timing description in the modifier
  DocC.

### Demo

- Restored the Mercari-style square carousel and wired it to the hero zoom transition.
- Merged the Remote/Kingfisher thumbnail stores into a single `ThumbnailStore(loader:)`.
- Fixed square, non-overflowing thumbnails in `ThumbnailGridView`.
- Fixed the Kingfisher screen so grid thumbnails load (previously stuck on spinners).

[2.0.0]: https://github.com/nakajijapan/PhotoSlider/compare/1.5.0...2.0.0
