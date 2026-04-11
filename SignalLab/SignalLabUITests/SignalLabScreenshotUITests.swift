//
//  SignalLabScreenshotUITests.swift
//  SignalLabUITests
//
//  Deterministic screenshots via launch arguments and stable accessibility identifiers.
//  Attachments appear in the test report (.xcresult → Attachments).
//

import XCTest

final class SignalLabScreenshotUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Standard text size

    /// Catalog root: explicit flag documents screenshot intent; avoids navigation setup taps.
    @MainActor
    func testScreenshot_catalog() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, catalogOnly: true, accessibilityDynamicType: false)

        let catalogList = app.descendants(matching: .any)["SignalLab.catalog.list"]
        XCTAssertTrue(catalogList.waitForExistence(timeout: 8), "Catalog list should appear with stable identifier.")
        XCTAssertTrue(app.navigationBars["SignalLab"].waitForExistence(timeout: 2))

        attachScreenshot(from: app, named: "signalLab-catalog")
    }

    /// Crash Lab detail without tapping through the list (deep link lab id).
    @MainActor
    func testScreenshot_crashLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "crash", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.crash"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Crash Lab detail root should appear with stable identifier.")
        XCTAssertTrue(app.navigationBars["Crash Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-crashLab-detail")
    }

    /// Breakpoint Lab detail for marketing / docs variety (same deep-link mechanism).
    @MainActor
    func testScreenshot_breakpointLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "breakpoint", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.breakpoint"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Breakpoint Lab detail root should appear with stable identifier.")
        let searchField = app.textFields["BreakpointLab.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))

        attachScreenshot(from: app, named: "signalLab-breakpointLab-detail")
    }

    /// Exception Breakpoint Lab (catalog id `break_on_failure`) — comparison prompt + scaffold.
    @MainActor
    func testScreenshot_exceptionBreakpointLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "break_on_failure", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.break_on_failure"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Exception Breakpoint Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Exception Breakpoint Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-exceptionBreakpointLab-detail")
    }

    // MARK: Accessibility text size (matches `grab_screenshot.sh --text-size accessibility`)

    @MainActor
    func testScreenshot_catalog_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, catalogOnly: true, accessibilityDynamicType: true)

        let catalogList = app.descendants(matching: .any)["SignalLab.catalog.list"]
        XCTAssertTrue(catalogList.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["SignalLab"].waitForExistence(timeout: 2))

        attachScreenshot(from: app, named: "signalLab-catalog-accessibility")
    }

    @MainActor
    func testScreenshot_crashLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "crash", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.crash"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Crash Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-crashLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_breakpointLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "breakpoint", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.breakpoint"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        let searchField = app.textFields["BreakpointLab.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))

        attachScreenshot(from: app, named: "signalLab-breakpointLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_exceptionBreakpointLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "break_on_failure", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.break_on_failure"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Exception Breakpoint Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-exceptionBreakpointLab-detail-accessibility")
    }

    // MARK: - Helpers

    private func launchScreenshotApp(
        _ app: XCUIApplication,
        catalogOnly: Bool = false,
        labID: String? = nil,
        accessibilityDynamicType: Bool
    ) {
        var args: [String] = []
        if catalogOnly {
            args.append("--uitesting-screenshot-catalog")
        }
        if let labID {
            args.append(contentsOf: ["--uitesting-screenshot-lab", labID])
        }
        if accessibilityDynamicType {
            args.append("--uitesting-screenshot-accessibility-dynamic-type")
        }
        app.launchArguments = args
        app.launch()
    }

    private func attachScreenshot(from app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
