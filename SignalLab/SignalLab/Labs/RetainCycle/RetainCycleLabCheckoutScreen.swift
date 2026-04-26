//
//  RetainCycleLabCheckoutScreen.swift
//  SignalLab
//
//  Plain app objects used as the Memory Graph target for Retain Cycle Lab.
//

import Foundation

/// The first named app object learners search for in Memory Graph.
final class RetainCycleLabCheckoutScreen {
    let title: String
    let subtotal: Decimal
    var closeButtonHandler: RetainCycleLabCloseButtonHandler?

    init(title: String, subtotal: Decimal) {
        self.title = title
        self.subtotal = subtotal
    }

    static func makeLeakingExample() -> RetainCycleLabCheckoutScreen {
        let checkoutScreen = RetainCycleLabCheckoutScreen(
            title: "Student checkout",
            subtotal: Decimal(120)
        )
        let closeButtonHandler = RetainCycleLabCloseButtonHandler(buttonTitle: "Close")

        checkoutScreen.closeButtonHandler = closeButtonHandler
        closeButtonHandler.checkoutScreen = checkoutScreen

        return checkoutScreen
    }

    func breakRetainCycleForReset() {
        closeButtonHandler?.checkoutScreen = nil
        closeButtonHandler = nil
    }
}

/// The second named app object in the intentional retain cycle.
final class RetainCycleLabCloseButtonHandler {
    let buttonTitle: String
    var checkoutScreen: RetainCycleLabCheckoutScreen?

    init(buttonTitle: String) {
        self.buttonTitle = buttonTitle
    }
}
