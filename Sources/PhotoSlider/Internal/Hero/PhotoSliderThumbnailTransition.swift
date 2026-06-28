//
//  PhotoSliderThumbnailTransition.swift
//  PhotoSlider
//
//  Represents the caller-supplied thumbnail (image + window-space frame) as a
//  `ZoomingAnimationControllerTransitioning`, so the existing v1.5.0
//  `ZoomingAnimationController` can drive the hero zoom without any change to its logic.
//
//  Direction (present vs dismiss) is expressed -- exactly as in v1.5.0 -- by swapping
//  which side plays the `source` role and which plays the `destination` role:
//  - Present: thumbnail is the `source` (the moving UIImageView starts at `windowFrame`),
//             `PhotoSliderViewController` is the `destination` (computes the fullscreen
//             centre frame to grow into).
//  - Dismiss: `PhotoSliderViewController` is the `source` (current page's UIImageView),
//             this adapter is the `destination` (shrinks the moving view back to
//             `windowFrame`).
//

import UIKit

@MainActor
final class PhotoSliderThumbnailTransition: ZoomingAnimationControllerTransitioning {

    /// The look of the image to animate. For present this is the caller's thumbnail image;
    /// for dismiss the moving view comes from the viewer, so this is only used when this
    /// adapter plays the `source` role.
    let image: UIImage?

    /// The thumbnail's frame already converted into the presenter window's coordinate space.
    let windowFrame: CGRect

    init(image: UIImage?, windowFrame: CGRect) {
        self.image = image
        self.windowFrame = windowFrame
    }

    func transitionSourceImageView() -> UIImageView {
        let imageView = UIImageView(frame: windowFrame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    func transitionDestinationImageView(sourceImageView: UIImageView) {
        sourceImageView.frame = windowFrame
    }
}
