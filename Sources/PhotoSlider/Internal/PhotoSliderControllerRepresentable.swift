//
//  PhotoSliderControllerRepresentable.swift
//  PhotoSlider
//
//  Bridges the UIKit interaction engine (`PhotoSliderViewController`) into SwiftUI.
//

import SwiftUI
import UIKit

struct PhotoSliderControllerRepresentable: UIViewControllerRepresentable {

    let items: [PhotoItem]
    @Binding var selection: Int
    let configuration: PhotoSliderConfiguration
    let imageLoader: any ImageLoader
    let callbacks: PhotoSliderCallbacks
    let onRequestDismiss: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    func makeUIViewController(context: Context) -> PhotoSliderViewController {
        let viewController = PhotoSliderViewController(
            items: items,
            configuration: configuration,
            imageLoader: imageLoader,
            initialPage: selection
        )
        context.coordinator.configure(
            viewController,
            callbacks: callbacks,
            onRequestDismiss: onRequestDismiss
        )
        return viewController
    }

    func updateUIViewController(_ viewController: PhotoSliderViewController, context: Context) {
        context.coordinator.configure(
            viewController,
            callbacks: callbacks,
            onRequestDismiss: onRequestDismiss
        )
        if selection != viewController.currentPage {
            viewController.scrollToPage(selection, animated: true)
        }
    }

    @MainActor
    final class Coordinator {

        @Binding private var selection: Int

        init(selection: Binding<Int>) {
            _selection = selection
        }

        func configure(
            _ viewController: PhotoSliderViewController,
            callbacks: PhotoSliderCallbacks,
            onRequestDismiss: @escaping () -> Void
        ) {
            viewController.onPageChanged = { [weak self] page in
                self?.selection = page
                callbacks.onPageChanged?(page)
            }
            viewController.onWillDismiss = { callbacks.onWillDismiss?() }
            viewController.onDidDismiss = { callbacks.onDidDismiss?() }
            viewController.onShare = { item in callbacks.onShare?(item) }
            // Long press is a no-op by default, matching v1.5.0's default behaviour.
            viewController.onLongPress = nil
            viewController.onRequestDismiss = onRequestDismiss
        }
    }
}
