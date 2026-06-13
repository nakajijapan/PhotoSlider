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
            List(Demo.allCases) { demo in
                NavigationLink(value: demo) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(demo.rawValue)
                            Text(demo.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: demo.systemImage)
                    }
                }
                .accessibilityIdentifier("demo-\(demo.rawValue)")
            }
            .navigationTitle("PhotoSlider 2.0")
            .navigationDestination(for: Demo.self, destination: destination)
            .accessibilityIdentifier("demo-list")
        }
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
