//
//  RetainCycleLabSessionTrackerTests.swift
//  SignalLabTests
//
//  Session counter behavior around RetainCycleLabDetailHeart lifetime (Fixed path).
//

import Foundation
import Testing
@testable import SignalLab

struct RetainCycleLabSessionTrackerTests {
    @Test @MainActor
    func fixedHeart_teardownEventuallyDecrementsLiveCount() async {
        let baseline = RetainCycleLabSessionTracker.shared.liveSessionCount
        var heart: RetainCycleLabDetailHeart? = RetainCycleLabDetailHeart(mode: .fixed)
        await Task.yield()
        #expect(RetainCycleLabSessionTracker.shared.liveSessionCount == baseline + 1)
        heart?.stopTimerForTeardown()
        heart = nil
        await Task.yield()
        await Task.yield()
        #expect(RetainCycleLabSessionTracker.shared.liveSessionCount == baseline)
    }
}
