//
//  RetainCycleLabSessionTrackerTests.swift
//  SignalLabTests
//
//  Session counter behavior around RetainCycleLabSession lifetime.
//

import Foundation
import Testing
@testable import SignalLab

struct RetainCycleLabSessionTrackerTests {
    @Test @MainActor
    func fixedSession_deallocatesAndDecrementsLiveCount() async {
        let baseline = RetainCycleLabSessionTracker.shared.liveSessionCount
        var session: RetainCycleLabSession? = RetainCycleLabSession(name: "test", mode: .fixed)
        await Task.yield()
        #expect(RetainCycleLabSessionTracker.shared.liveSessionCount == baseline + 1)
        session = nil  // [weak self] in handler — no cycle — session deallocates
        await Task.yield()
        await Task.yield()
        #expect(RetainCycleLabSessionTracker.shared.liveSessionCount == baseline)
    }
}
