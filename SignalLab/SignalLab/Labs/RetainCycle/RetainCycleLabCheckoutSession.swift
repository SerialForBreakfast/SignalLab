//
//  RetainCycleLabCheckoutSession.swift
//  SignalLab
//
//  Closure-based retain cycle: Broken captures self strongly; Fixed uses [weak self].
//

import Combine
import Foundation

/// A checkout session created each time the Retain Cycle Lab sheet opens.
///
/// - **Broken:** `completionHandler` captures `self` strongly →
///   `RetainCycleLabCheckoutSession -> completionHandler -> RetainCycleLabCheckoutSession`.
///   After the sheet closes, the checkout session cannot deallocate.
/// - **Fixed:** `completionHandler` uses `[weak self]`, so the checkout session deallocates on dismiss.
final class RetainCycleLabCheckoutSession: ObservableObject {
    /// The checkout name shown in the sheet.
    let checkoutName: String

    /// Stored completion handler. In Broken mode this captures `self` strongly, preventing deallocation.
    var completionHandler: (() -> Void)?

    init(name: String, mode: LabImplementationMode) {
        self.checkoutName = name
        RetainCycleLabSessionTracker.notifySessionStarted()
        switch mode {
        case .broken:
            // Broken: strong self capture creates checkout session -> completionHandler -> checkout session.
            completionHandler = {
                self.handleCompletion()
            }
        case .fixed:
            // Fixed: weak self breaks the cycle, so the checkout session can deallocate when closed.
            completionHandler = { [weak self] in
                self?.handleCompletion()
            }
        }
    }

    /// Called by the stored completion handler.
    ///
    /// In a production app this would process an async checkout result. Here it exists
    /// so the closure has a meaningful capture target.
    private func handleCompletion() {}

    deinit {
        RetainCycleLabSessionTracker.notifySessionEnded()
    }
}
