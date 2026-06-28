# PhotoSlider for Swift

[![License](https://img.shields.io/github/license/nakajijapan/PhotoSlider.svg?style=flat)](https://github.com/nakajijapan/PhotoSlider/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-blue.svg?style=flat)](https://www.apple.com/ios/)
[![Language](https://img.shields.io/badge/language-Swift%206-orange.svg)](https://swift.org)
[![Backers on Open Collective](https://opencollective.com/PhotoSlider/backers/badge.svg)](#backers) 
[![Sponsors on Open Collective](https://opencollective.com/PhotoSlider/sponsors/badge.svg)](#sponsors) 

PhotoSlider is a simple, full-screen photo viewer. Swipe horizontally to page, swipe
vertically to dismiss, pinch / double-tap to zoom.

<img src="https://raw.githubusercontent.com/nakajijapan/PhotoSlider/master/demo.gif" width="300" />

## 2.0 — SwiftUI rewrite

PhotoSlider 2.0 has a brand-new **SwiftUI-first API**, while keeping the **exact same
interactions** as 1.x. The proven `UIScrollView`-based interaction engine (paging,
vertical swipe-to-dismiss with linear background fade, pinch / tap-point double-tap zoom
with momentum & bounce) is reused internally and wrapped for SwiftUI, so the feel is
byte-for-byte identical to 1.5.0.

What changed:

- ✅ SwiftUI API: `PhotoSliderView`, `.photoSlider(isPresented:...)`
- ✅ Swift 6 / strict concurrency, iOS 18+
- ✅ Kingfisher is **no longer required** — image loading is abstracted behind the
  `ImageLoader` protocol (default is a `URLSession`-based loader). Kingfisher is available
  as an optional `PhotoSliderKingfisher` product.
- ⚠️ The UIKit API (`PhotoSlider.ViewController`, `Photo`, `PhotoSliderDelegate`, …) is
  removed. Use 1.5.0 if you need it.

## Requirements

- Xcode 16+
- Swift 6
- iOS 18+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/nakajijapan/PhotoSlider.git", from: "2.0.0"),
]
```

Add the product(s) you need to your target:

```swift
.product(name: "PhotoSlider", package: "PhotoSlider"),
// Optional — only if you want Kingfisher-backed image loading:
.product(name: "PhotoSliderKingfisher", package: "PhotoSlider"),
```

## Usage

### Present full screen

```swift
import SwiftUI
import PhotoSlider

struct GalleryScreen: View {
    @State private var isPresented = false
    @State private var selection = 0

    let photos: [PhotoItem] = [
        .init(source: .remote(URL(string: "https://example.com/a.jpg")!), caption: "Aurora"),
        .init(source: .remote(URL(string: "https://example.com/b.jpg")!)),
        .init(source: .remote(URL(string: "https://example.com/c.jpg")!), caption: "Forest"),
    ]

    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 100))]) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, _ in
                Button {
                    selection = index
                    isPresented = true
                } label: {
                    Color.gray.aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .photoSlider(isPresented: $isPresented, photos: photos, selection: $selection)
    }
}
```

You can also drop `PhotoSliderView` directly inside your own `.fullScreenCover` / `.sheet`:

```swift
.fullScreenCover(isPresented: $isPresented) {
    PhotoSliderView(photos: photos, selection: $selection)
}
```

### Hero (zoom) transition

Use the `sourceFrame:` overload to present with a thumbnail ⇄ full-screen **hero (zoom)
transition** instead of a cross-fade. On present, the image zooms up from the tapped
thumbnail; **on dismiss it zooms back down to the thumbnail of the current page** — so if
the user swipes to another page inside the viewer, it returns to *that* thumbnail's slot.

`sourceFrame(index)` returns the `CGRect` the thumbnail occupies in the **global**
coordinate space (`proxy.frame(in: .global)`). Record each thumbnail's frame as it lays
out, then return it from the closure. Return `nil` (or an empty / off-screen rect) to fall
back to the cross-fade transition for that page.

```swift
struct CarouselScreen: View {
    let photos: [PhotoItem]
    @State private var selection = 0
    @State private var isPresented = false
    // Frame each thumbnail occupies in global coordinates, keyed by index.
    @State private var frames: [Int: CGRect] = [:]

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                Button { isPresented = true } label: {
                    thumbnail(for: photo)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { frames[index] = proxy.frame(in: .global) }
                            .onChange(of: proxy.frame(in: .global)) { _, new in
                                frames[index] = new
                            }
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            sourceFrame: { index in frames[index] } // nil → cross-fade fallback
        )
    }
}
```

`selection` is the source of truth for the hero target on both present and dismiss: the
dismiss target is re-evaluated against the current `selection`, so the zoom-out always
lands on whatever page is showing when the viewer closes.

#### Hide the source thumbnail during the transition

During a hero transition the image zooms from the source thumbnail, but **your original
thumbnail stays on screen** — so for a moment the same photo is visible twice (the moving
hero image *and* the thumbnail underneath it). The recommended pattern is to **hide your
thumbnail synchronously in the tap action** (set `hiddenIndex = index` right where you set
`isPresented = true`) and use `onPhotoSliderSourceVisibilityChange` only to **restore** it
when the close animation finishes. Hiding on tap guarantees the thumbnail is already gone
before the zoom grows; the library's `(index, isHidden: true)` arrives the tick *after* the
tap, so relying on it to hide can leave one frame of double-display.

The restore call, `(index, isHidden: false)`, fires only **after** the dismiss animation has
fully zoomed back down — so the thumbnail never re-appears while the image is still shrinking
toward it. The `index` passed back on restore is the same one you hid, so even if the user
swiped to another page inside the viewer the right thumbnail is always restored. The callback
fires **only** on the hero (`sourceFrame:`) path; it is never called for the cross-fade
present or when `sourceFrame` falls back to a fade. Add it **after** `photoSlider(...)` — the
callback flows down to the presentation host via the environment, so the modifier has to wrap
(be an ancestor of) `.photoSlider(...)`, not precede it.

```swift
struct CarouselScreen: View {
    let photos: [PhotoItem]
    @State private var selection = 0
    @State private var isPresented = false
    @State private var frames: [Int: CGRect] = [:]
    // The page index to hide during the hero transition (nil = nothing hidden).
    @State private var hiddenIndex: Int?

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                Button {
                    // Hide synchronously on tap, before the zoom grows — no double-display.
                    hiddenIndex = index
                    isPresented = true
                } label: {
                    thumbnail(for: photo)
                }
                // Hide this page's thumbnail while it's the hero source.
                .opacity(hiddenIndex == index ? 0 : 1)
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            sourceFrame: { index in frames[index] }
        )
        // Must come after `.photoSlider(...)`.
        .onPhotoSliderSourceVisibilityChange { _, isHidden in
            // dismiss done: (index, false) → restore (hiding was already done on tap).
            if !isHidden { hiddenIndex = nil }
        }
    }
}
```

### Photo sources

```swift
PhotoItem(source: .remote(url))          // loaded via ImageLoader
PhotoItem(source: .uiImage(uiImage))     // already-decoded UIImage
PhotoItem(source: .data(jpegData))       // in-memory binary
```

### Configuration

```swift
var config = PhotoSliderConfiguration()
config.backgroundColor = .black
config.showsPageIndicator = true
config.showsCloseButton = true
config.showsShareButton = false
config.showsCaption = true
config.enableSwipeToDismiss = true
config.enablePinchToZoom = true
config.maxZoomScale = 3.0
config.dismissProgressThreshold = 0.4    // 40% of screen height, same as v1.5.0

PhotoSliderView(photos: photos, selection: $selection, configuration: config)
```

### Callbacks (formerly `PhotoSliderDelegate`)

```swift
GalleryScreen()
    .photoSlider(isPresented: $isPresented, photos: photos, selection: $selection)
    // The callbacks must come after `.photoSlider(...)` so they wrap the
    // presentation host that reads them from the environment.
    .onPhotoSliderPageChanged { index in print("page = \(index)") }
    .onPhotoSliderWillDismiss { print("will dismiss") }
    .onPhotoSliderDidDismiss { print("did dismiss") }
    .onPhotoSliderShare { item in /* present a ShareLink / UIActivityViewController */ }
```

Or inject them all at once:

```swift
.photoSliderCallbacks(.init(
    onPageChanged: { index in ... },
    onDidDismiss: { ... },
    onShare: { item in ... }
))
```

### Custom image loader

The default loader uses `URLSession` + `URLCache`. To plug in SDWebImage, Nuke, or your
own pipeline, conform to `ImageLoader`:

```swift
struct MyImageLoader: ImageLoader {
    func loadImage(from url: URL) async throws -> PlatformImage {
        // fetch + decode, return a UIImage
    }
}

PhotoSliderView(photos: photos, selection: $selection, imageLoader: MyImageLoader())
```

### Kingfisher

```swift
import PhotoSlider
import PhotoSliderKingfisher

PhotoSliderView(photos: photos, selection: $selection, imageLoader: .kingfisher())
```

## Author

nakajijapan

### Special Thanks

- hikarock
- yhkaplan
- seapy
- antrix1989

## Contributors

This project exists thanks to all the people who contribute. 
<a href="https://github.com/nakajijapan/PhotoSlider/graphs/contributors"><img src="https://opencollective.com/PhotoSlider/contributors.svg?width=890&button=false" /></a>


## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/PhotoSlider#backer)]

<a href="https://opencollective.com/PhotoSlider#backers" target="_blank"><img src="https://opencollective.com/PhotoSlider/backers.svg?width=890"></a>


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/PhotoSlider#sponsor)]

<a href="https://opencollective.com/PhotoSlider/sponsor/0/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/1/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/2/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/3/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/4/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/5/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/6/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/7/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/8/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/PhotoSlider/sponsor/9/website" target="_blank"><img src="https://opencollective.com/PhotoSlider/sponsor/9/avatar.svg"></a>



## License

PhotoSlider is available under the MIT license. See the LICENSE file for more info.
