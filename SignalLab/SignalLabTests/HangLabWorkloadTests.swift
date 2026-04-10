//
//  HangLabWorkloadTests.swift
//  SignalLabTests
//
//  Determinism of Hang Lab CPU workload (small iteration counts for speed).
//

import Foundation
import Testing
@testable import SignalLab

struct HangLabWorkloadTests {
    @Test func simulateReportProcessing_isDeterministicForSameInputs() {
        let seed = 42
        let iterations = 10_000
        let first = HangLabWorkload.simulateReportProcessing(seed: seed, iterationCount: iterations)
        let second = HangLabWorkload.simulateReportProcessing(seed: seed, iterationCount: iterations)
        #expect(first == second)
    }

    @Test func simulateReportProcessing_differsWhenSeedChanges() {
        let iterations = 5_000
        let a = HangLabWorkload.simulateReportProcessing(seed: 1, iterationCount: iterations)
        let b = HangLabWorkload.simulateReportProcessing(seed: 2, iterationCount: iterations)
        #expect(a != b)
    }
}
