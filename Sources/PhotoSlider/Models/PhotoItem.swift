//
//  PhotoItem.swift
//  PhotoSlider
//

import Foundation

/// An immutable model representing a single photo displayed by PhotoSlider.
///
/// `id` is a `UUID` newly issued at `init` time. Even for the same image, separate instances have separate IDs.
/// To preserve identity across reordering or diff updates, hold onto the created `PhotoItem` on the caller side.
///
/// ```swift
/// let photos: [PhotoItem] = [
///     .init(source: .remote(url), caption: "Aurora"),
///     .init(source: .uiImage(localImage)),
/// ]
/// ```
public struct PhotoItem: Identifiable, Hashable, Sendable {

    /// A unique identifier. Assigned automatically at `init` time.
    public let id: UUID

    /// The image source.
    public var source: PhotoSource

    /// A caption shown at the bottom of the image. When `nil`, no caption is shown for that page.
    public var caption: String?

    /// Creates a photo.
    ///
    /// - Parameters:
    ///   - source: The image source.
    ///   - caption: A caption shown at the bottom of the image. Defaults to `nil` (hidden).
    public init(source: PhotoSource, caption: String? = nil) {
        self.id = UUID()
        self.source = source
        self.caption = caption
    }
}
