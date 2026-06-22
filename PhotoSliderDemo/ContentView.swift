//
//  ContentView.swift
//  PhotoSliderDemo
//
//  Entry screen listing the PhotoSlider 2.0 demos.
//

import SwiftUI

/// The demos available from the entry screen.
enum Demo: String, CaseIterable, Identifiable {
    case local = "Local images (uiImage)"
    case remote = "Remote images (default loader)"
    case kingfisher = "Remote images (Kingfisher)"
    case callbacks = "Configuration & callbacks"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .local: "photo.on.rectangle"
        case .remote: "cloud"
        case .kingfisher: "bolt.horizontal.circle"
        case .callbacks: "slider.horizontal.3"
        }
    }

    var subtitle: String {
        switch self {
        case .local: "Bundled UIImages, works offline"
        case .remote: "URLSession-based DefaultImageLoader"
        case .kingfisher: "imageLoader: .kingfisher()"
        case .callbacks: "showsShareButton + every callback"
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            CarouselDemoView()
                .navigationDestination(for: Demo.self, destination: destination)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        demoMenu
                    }
                }
        }
    }

    /// Right-bar menu giving access to the original four 2.0 demos.
    private var demoMenu: some View {
        Menu {
            ForEach(Demo.allCases) { demo in
                NavigationLink(value: demo) {
                    Label(demo.rawValue, systemImage: demo.systemImage)
                }
                .accessibilityIdentifier("demo-\(demo.rawValue)")
            }
        } label: {
            Image(systemName: "list.bullet")
        }
        .accessibilityIdentifier("demo-menu")
    }

    @ViewBuilder
    private func destination(for demo: Demo) -> some View {
        switch demo {
        case .local: LocalPhotosDemoView()
        case .remote: RemotePhotosDemoView()
        case .kingfisher: KingfisherDemoView()
        case .callbacks: CallbacksDemoView()
        }
    }
}

#Preview {
    ContentView()
}
