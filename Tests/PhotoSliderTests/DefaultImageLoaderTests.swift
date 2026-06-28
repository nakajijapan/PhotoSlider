//
//  DefaultImageLoaderTests.swift
//  PhotoSliderTests
//

import XCTest
import UIKit
@testable import PhotoSlider

final class DefaultImageLoaderTests: XCTestCase {

    private func makeLoader() -> DefaultImageLoader {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return DefaultImageLoader(session: URLSession(configuration: configuration))
    }

    private func samplePNGData() throws -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        return try XCTUnwrap(image.pngData())
    }

    func testLoadsPNG() async throws {
        MockURLProtocol.responseData = try samplePNGData()
        MockURLProtocol.statusCode = 200
        let loader = makeLoader()
        let image = try await loader.loadImage(from: URL(string: "https://example.com/a.png")!)
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testBadStatusThrows() async throws {
        MockURLProtocol.responseData = Data()
        MockURLProtocol.statusCode = 404
        let loader = makeLoader()
        do {
            _ = try await loader.loadImage(from: URL(string: "https://example.com/b.png")!)
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? DefaultImageLoaderError, .badStatus(404))
        }
    }

    func testProgressReachesOne() async throws {
        MockURLProtocol.responseData = try samplePNGData()
        MockURLProtocol.statusCode = 200
        let loader = makeLoader()
        let collector = await ProgressCollector()
        _ = try await loader.loadImage(
            from: URL(string: "https://example.com/c.png")!,
            onProgress: { progress in collector.append(progress) }
        )
        let lastValue: Double? = await collector.last
        let last = try XCTUnwrap(lastValue)
        XCTAssertEqual(last, 1.0, accuracy: 0.0001)
    }

    @MainActor
    final class ProgressCollector {
        private(set) var values: [Double] = []
        func append(_ value: Double) { values.append(value) }
        var last: Double? { values.last }
    }
}
