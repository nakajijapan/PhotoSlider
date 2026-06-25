//
//  CallbacksDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates configuration + per-event callback modifiers.
//

import SwiftUI
import PhotoSlider

/// Callbacks demo: custom configuration (share button on) plus every callback,
/// surfacing the latest event both via `print` and on screen.
struct CallbacksDemoView: View {

    private let photos = DemoData.localPhotos()
    @State private var isPresented = false
    @State private var selection = 0
    @State private var lastEvent = "No event yet"

    private var configuration: PhotoSliderConfiguration {
        var config = PhotoSliderConfiguration.default
        config.showsShareButton = true
        config.showsCaption = true
        config.maxZoomScale = 4.0
        return config
    }

    var body: some View {
        VStack(spacing: 0) {
            eventBanner
            ThumbnailGridView(
                photos: photos,
                thumbnailProvider: { photo in
                    if case let .uiImage(image) = photo.source { return image }
                    return nil
                },
                onTap: { index in
                    selection = index
                    isPresented = true
                }
            )
        }
        .navigationTitle("Callbacks")
        .navigationBarTitleDisplayMode(.inline)
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            configuration: configuration
        )
        // The callback modifiers install their closures via `transformEnvironment`,
        // which only flows down to descendants. `.photoSlider(...)` reads the
        // callbacks from its *own* environment (ancestors), so these must be
        // attached *after* (outside) `.photoSlider(...)` to reach it — attaching
        // them before (inside) would leave the callbacks `nil` and they would
        // never fire.
        .onPhotoSliderPageChanged { index in
            report("pageChanged → \(index)")
        }
        .onPhotoSliderWillDismiss {
            report("willDismiss")
        }
        .onPhotoSliderDidDismiss {
            report("didDismiss")
        }
        .onPhotoSliderShare { item in
            report("share → \(item.caption ?? "untitled")")
        }
        .onPhotoSliderRequestDelete { item in
            report("requestDelete → \(item.caption ?? "untitled")")
            return true
        }
    }

    @ViewBuilder
    private var eventBanner: some View {
        Text(lastEvent)
            .font(.footnote.monospaced())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(.thinMaterial)
            .accessibilityIdentifier("event-banner")
    }

    private func report(_ message: String) {
        print("[PhotoSlider] \(message)")
        lastEvent = message
    }
}

#Preview {
    NavigationStack {
        CallbacksDemoView()
    }
}
