//
//  DefaultImageLoader.swift
//  PhotoSlider
//

import UIKit

/// Errors thrown by ``DefaultImageLoader``.
public enum DefaultImageLoaderError: Error, Sendable, Equatable {
    /// The HTTP status code was not in the 2xx range.
    case badStatus(Int)
    /// The fetched data could not be decoded as an image.
    case decodingFailed
}

/// The standard ``ImageLoader`` implementation, based on `URLSession` + `URLCache`.
///
/// It has no Kingfisher dependency. Sharing a single instance per process
/// (``default`` / ``shared``) is recommended.
public struct DefaultImageLoader: ImageLoader {

    /// The shared instance. Uses a `URLSession` backed by an image-oriented `URLCache`.
    public static let shared = DefaultImageLoader(session: DefaultImageLoader.makeDefaultSession())

    private let session: URLSession

    /// Initializes with a custom `URLSession`.
    /// - Parameter session: The session to use. Defaults to `URLSession.shared`.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func loadImage(from url: URL) async throws -> PlatformImage {
        let (data, response) = try await session.data(for: URLRequest(url: url))
        try Self.validate(response)
        guard let image = UIImage(data: data) else {
            throw DefaultImageLoaderError.decodingFailed
        }
        return image
    }

    public func loadImage(
        from url: URL,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void
    ) async throws -> PlatformImage {
        let (asyncBytes, response) = try await session.bytes(for: URLRequest(url: url))
        try Self.validate(response)

        let expected = response.expectedContentLength
        var data = Data()
        if expected > 0 {
            data.reserveCapacity(Int(expected))
        }

        var lastReported = -1.0
        for try await byte in asyncBytes {
            try Task.checkCancellation()
            data.append(byte)
            if expected > 0 {
                let progress = min(1.0, Double(data.count) / Double(expected))
                if progress - lastReported >= 0.02 {
                    lastReported = progress
                    await MainActor.run { onProgress(progress) }
                }
            }
        }
        await MainActor.run { onProgress(1.0) }

        guard let image = UIImage(data: data) else {
            throw DefaultImageLoaderError.decodingFailed
        }
        return image
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw DefaultImageLoaderError.badStatus(http.statusCode)
        }
    }

    private static func makeDefaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        return URLSession(configuration: configuration)
    }
}

public extension ImageLoader where Self == DefaultImageLoader {
    /// The default `URLSession`-based loader.
    static var `default`: DefaultImageLoader { DefaultImageLoader.shared }
}
