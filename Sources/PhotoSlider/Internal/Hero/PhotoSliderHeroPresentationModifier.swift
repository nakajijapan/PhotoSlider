//
//  PhotoSliderHeroPresentationModifier.swift
//  PhotoSlider
//
//  Drives the hero (zoom) presentation path used by the `photoSlider(...:sourceFrame:)`
//  overload. Instead of `.fullScreenCover`, it attaches an invisible UIKit bridge that
//  presents `PhotoSliderViewController` directly so the zoom transition can run.
//

import SwiftUI

struct PhotoSliderHeroPresentationModifier: ViewModifier {

    @Binding var isPresented: Bool
    let photos: [PhotoItem]
    @Binding var selection: Int
    let configuration: PhotoSliderConfiguration
    let imageLoader: any ImageLoader
    let sourceFrame: (Int) -> CGRect?

    @Environment(\.photoSliderCallbacks) private var callbacks

    func body(content: Content) -> some View {
        content.background(
            PhotoSliderHeroPresenter(
                isPresented: $isPresented,
                photos: photos,
                selection: $selection,
                configuration: configuration,
                imageLoader: imageLoader,
                callbacks: callbacks,
                sourceFrame: sourceFrame
            )
            // Zero-size, non-interactive: it exists only to host the UIKit presentation.
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        )
    }
}
