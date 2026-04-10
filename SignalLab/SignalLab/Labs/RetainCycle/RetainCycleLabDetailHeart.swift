//
//  RetainCycleLabDetailHeart.swift
//  SignalLab
//
//  Repeating timer owner: Broken mode retains self strongly (leak); Fixed mode tears down on dismiss.
//

import Combine
import Foundation

/// Owns a repeating `Timer` for the Retain Cycle Lab detail sheet.
///
/// - **Broken:** The timer’s closure captures `self` strongly, so the timer keeps the heart alive after the sheet is dismissed.
/// - **Fixed:** The view calls ``stopTimerForTeardown()`` from `onDisappear`, invalidating the timer so the heart can deallocate.
///
/// ## Concurrency
/// `Timer` targets the main run loop; UI updates use Combine on the main actor.
final class RetainCycleLabDetailHeart: ObservableObject {
    /// Fires periodically so the learner can see activity in the UI while investigating.
    @Published private(set) var tickCount: Int = 0

    private var timer: Timer?
    private let mode: LabImplementationMode

    /// Creates a heart, starts the timer, and registers with ``RetainCycleLabSessionTracker``.
    init(mode: LabImplementationMode) {
        self.mode = mode
        RetainCycleLabSessionTracker.notifySessionStarted()
        startTimer()
    }

    private func startTimer() {
        switch mode {
        case .broken:
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
                Task { @MainActor in
                    self.tickCount += 1
                }
            }
        case .fixed:
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.tickCount += 1
                }
            }
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    /// Stops the timer so nothing keeps a strong reference to this object (Fixed-mode teaching path).
    func stopTimerForTeardown() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
        RetainCycleLabSessionTracker.notifySessionEnded()
    }
}
