//
//  HangLabWorkload.swift
//  SignalLab
//
//  CPU-heavy synchronous "report processing" that blocks the main thread.
//

import Foundation

/// Artificial report pipeline work for Hang Lab.
///
/// The implementation is **pure** and **synchronous** — called directly on the main actor,
/// which blocks touches and animations while the work runs.
///
/// ## Concurrency
/// Members are ``nonisolated`` so the symbol can be called from any context without crossing
/// an inferred main-actor boundary.
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
