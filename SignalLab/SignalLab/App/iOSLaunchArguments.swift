//
//  iOSLaunchArguments.swift
//  SignalLab
//
//  Parses ProcessInfo launch arguments for UI tests, screenshots, and deterministic cold starts.
//

import Foundation

/// Launch flags read at startup (UI tests and optional demo modes).
///
/// Keep parsing tolerant: production launches omit these flags entirely.
enum SignalLabLaunchArguments {

    /// When followed by a lab slug, ``iOSLabCatalogView`` pushes that lab’s detail on first appear.
    ///
    /// Example: `--uitesting-screenshot-lab crash`
    static var uitestingScreenshotLabID: String? {
        value(following: "--uitesting-screenshot-lab")
    }

    /// Prefer including this when capturing catalog-only screenshots so intent is explicit in logs and tests.
    static var uitestingScreenshotCatalogOnly: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting-screenshot-catalog")
    }

    /// UI tests pass this with catalog / lab flags so ``grab_screenshot.sh`` can capture accessibility-sized layouts.
    static var uitestingScreenshotAccessibilityDynamicType: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting-screenshot-accessibility-dynamic-type")
    }

    private static func value(following flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag) else { return nil }
        let valueIndex = args.index(after: index)
        guard valueIndex < args.endIndex else { return nil }
        let next = String(args[valueIndex])
        if next.hasPrefix("-") { return nil }
        return next
    }
}
