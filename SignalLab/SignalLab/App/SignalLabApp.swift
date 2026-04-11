//
//  SignalLabApp.swift
//  SignalLab
//
//  Created by Joseph McCraw on 4/9/26.
//

import OSLog
import SwiftUI

@main
struct SignalLabApp: App {
    init() {
        SignalLabLog.appLifecycle.notice("SignalLab launching—subsystem=\(SignalLabLog.subsystemForDiagnostics)")
    }

    var body: some Scene {
        WindowGroup {
            iOSLabCatalogView(initialDeepLinkLabID: SignalLabLaunchArguments.uitestingScreenshotLabID)
                .signalLabScreenshotDynamicTypeIfNeeded()
        }
    }
}

// MARK: - Screenshot / UI test layout

private extension View {
    /// Applies a large dynamic type size when UI tests request accessibility-style captures (see `grab_screenshot.sh --text-size accessibility`).
    @ViewBuilder
    func signalLabScreenshotDynamicTypeIfNeeded() -> some View {
        if SignalLabLaunchArguments.uitestingScreenshotAccessibilityDynamicType {
            dynamicTypeSize(.accessibility3)
        } else {
            self
        }
    }
}
