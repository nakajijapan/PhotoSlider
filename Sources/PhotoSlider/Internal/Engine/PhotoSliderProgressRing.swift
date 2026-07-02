//
//  PhotoSliderProgressRing.swift
//  PhotoSlider
//
//  SwiftUI-native reimplementation of `PhotoSliderProgressRingView` (CAShapeLayer).
//
//  Spike for issue #125 (verify feasibility of a fully-SwiftUI engine). This is the
//  lowest-risk migration candidate: the loading ring is pure drawing with no gesture or
//  scroll coupling, so it can be reproduced pixel-for-pixel with `Circle().trim().stroke()`.
//
//  Geometry is matched to the UIKit original exactly:
//  - A 40x40 view, radius-20 circle, so the 4pt stroke straddles 18...22 — identical to the
//    UIKit `UIBezierPath(arcCenter:radius:20...)` in a 40x40 frame.
//  - The original arc runs from -π/2 to (π + 1.5): a ~355.9° sweep starting at the top and
//    growing clockwise, NOT a full 360°. `sweepFraction` reproduces that small gap.
//  - Faint track: white @ 0.2 opacity. Progress arc: solid white, round line cap.
//  - Progress changes animate linearly over 0.05s (matches the original CABasicAnimation).
//
//  Not yet wired into `PhotoSliderEngineImageView` — kept standalone so the visual can be
//  compared side-by-side against the UIKit ring before committing to the swap.
//

import SwiftUI

struct PhotoSliderProgressRing: View {

    /// Download progress in `0.0...1.0`. Values outside the range are clamped.
    var progress: Double

    // The UIKit original sweeps from -π/2 to (π + 1.5) — ~355.9° of the full circle, leaving a
    // small gap at the top. `strokeEnd = progress` there fills a fraction of *that* arc, so the
    // SwiftUI trim end must be scaled by this same fraction to stay faithful.
    private let sweepFraction = (Double.pi + 1.5 - (-Double.pi / 2)) / (2 * Double.pi)
    private let lineWidth: CGFloat = 4
    private let ringSize: CGFloat = 40

    var body: some View {
        ZStack {
            // Faint background track (full arc).
            ring(to: sweepFraction)
                .stroke(Color.white.opacity(0.2),
                        style: StrokeStyle(lineWidth: lineWidth))

            // Determinate progress arc.
            ring(to: sweepFraction * progress.clampedTo01)
                .stroke(Color.white,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .animation(.linear(duration: 0.05), value: progress)
        }
        .frame(width: ringSize, height: ringSize)
    }

    /// A circle trimmed to `end` (fraction of the full circle) and rotated so it starts at the
    /// top (12 o'clock) instead of SwiftUI's default 3 o'clock, growing clockwise.
    private func ring(to end: Double) -> some Shape {
        Circle()
            .trim(from: 0, to: end)
            .rotation(.degrees(-90))
    }
}

private extension Double {
    var clampedTo01: Double { min(max(self, 0), 1) }
}

#if DEBUG
private struct PhotoSliderProgressRingPreviewHost: View {
    @State private var progress: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                PhotoSliderProgressRing(progress: progress)
                Slider(value: $progress, in: 0...1)
                    .frame(width: 220)
                    .tint(.white)
                Text(String(format: "%.0f%%", progress * 100))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
    }
}

#Preview("Interactive") {
    PhotoSliderProgressRingPreviewHost()
}

#Preview("Snapshots") {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 24) {
            ForEach([0.0, 0.25, 0.6, 1.0], id: \.self) { value in
                PhotoSliderProgressRing(progress: value)
            }
        }
    }
}
#endif
