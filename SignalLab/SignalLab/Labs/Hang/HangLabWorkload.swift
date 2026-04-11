//
//  HangLabWorkload.swift
//  SignalLab
//
//  CPU-heavy synchronous "report processing" used to freeze the main thread in Broken mode.
//

import Foundation

/// Artificial report pipeline work for Hang Lab.
///
/// The implementation is **pure** and **synchronous** on purpose: Broken mode calls it directly on the main actor,
/// which blocks touches and animations; Fixed mode runs the same function off the main actor.
///
/// ## Concurrency
/// Members are ``nonisolated`` so the same symbol runs on the main actor (Broken) or inside ``Task/detached`` (Fixed)
/// without crossing an inferred main-actor boundary.
enum HangLabWorkload {
    /// Default loop count tuned for a noticeable main-thread stall on simulator devices (adjust if too fast/slow).
    nonisolated static let defaultIterationCount = 4_000_000

    /// Deterministic pseudo-report checksum after CPU-heavy looping.
    ///
    /// - Parameters:
    ///   - seed: Varies per invocation so results differ between runs.
    ///   - iterationCount: Loop bound; use a smaller value in unit tests.
    nonisolated static func simulateReportProcessing(seed: Int, iterationCount: Int = defaultIterationCount) -> Int {
        let modulus: Int64 = 1_000_000_007
        var accumulator = Int64(seed % Int(modulus))
        for i in 0..<iterationCount {
            accumulator = (accumulator * 31 + Int64(i)) % modulus
        }
        return Int((accumulator % modulus + modulus) % modulus)
    }
}
