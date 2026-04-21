//
//  RetainCycleLabSession.swift
//  SignalLab
//
//  Closure-based retain cycle: Broken captures self strongly; Fixed uses [weak self].
//

import Combine
import Foundation

/// A session object created each time the Retain Cycle Lab detail sheet opens.
///
/// - **Broken:** `completionHandler` captures `self` strongly →
///   `RetainCycleLabSession → completionHandler → RetainCycleLabSession` (retain cycle).
///   After the sheet closes, the session cannot deallocate.
/// - **Fixed:** `completionHandler` uses `[weak self]` — no cycle, session deallocates on dismiss.
final class RetainCycleLabSession: ObservableObject {
    /// The session name — shown in the sheet and visible in the Memory Graph node label.
    let sessionName: String

    /// Stored completion handler. In Broken mode this captures `self` strongly, preventing deallocation.
    var completionHandler: (() -> Void)?

    init(name: String, mode: LabImplementationMode) {
        self.sessionName = name
        RetainCycleLabSessionTracker.notifySessionStarted()
        switch mode {
        case .broken:
            // Broken: strong [self] capture — self → completionHandler → self
            completionHandler = {
                self.handleCompletion()
            }
        case .fixed:
            // Fixed: [weak self] breaks the cycle — session deallocates when sheet closes
            completionHandler = { [weak self] in
                self?.handleCompletion()
            }
        }
    }

    /// Called by the stored completion handler.
    ///
    /// In a production app this would process an async result. Here it exists so the
    /// closure has a meaningful capture target — making the retain cycle concrete.
    private func handleCompletion() {}

    deinit {
        RetainCycleLabSessionTracker.notifySessionEnded()
    }
}
