//
//  DefaultImageLoader.swift
//  PhotoSlider
//

import UIKit

/// ``DefaultImageLoader`` が投げるエラー。
public enum DefaultImageLoaderError: Error, Sendable, Equatable {
    /// HTTP ステータスコードが 2xx 以外だった。
    case badStatus(Int)
    /// 取得したデータを画像としてデコードできなかった。
    case decodingFailed
}

/// `URLSession` + `URLCache` ベースの標準 ``ImageLoader`` 実装。
///
/// Kingfisher には依存しません。プロセスごとに 1 インスタンス（``default`` / ``shared``）を
/// 共有することを推奨します。
public struct DefaultImageLoader: ImageLoader {

    /// 共有インスタンス。内部に画像向けの `URLCache` を持つ `URLSession` を使います。
    public static let shared = DefaultImageLoader(session: DefaultImageLoader.makeDefaultSession())

    private let session: URLSession

    /// 独自の `URLSession` で初期化します。
    /// - Parameter session: 利用するセッション。省略時は `URLSession.shared`。
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
    /// `URLSession` ベースのデフォルトローダー。
    static var `default`: DefaultImageLoader { DefaultImageLoader.shared }
}
