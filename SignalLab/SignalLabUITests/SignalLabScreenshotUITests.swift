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

    /// Retain Cycle Lab — leak counter + sheet flow (shared detail scaffold).
    @MainActor
    func testScreenshot_retainCycleLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "retain_cycle", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.retain_cycle"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Retain Cycle Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Retain Cycle Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-retainCycleLab-detail")
    }

    /// Hang Lab — main-thread vs off-main workload messaging.
    @MainActor
    func testScreenshot_hangLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "hang", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.hang"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Hang Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Hang Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-hangLab-detail")
    }

    /// CPU Hotspot Lab — live search field + 500-item event catalog.
    @MainActor
    func testScreenshot_cpuHotspotLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "cpu_hotspot", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.cpu_hotspot"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "CPU Hotspot Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["CPU Hotspot Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)
        XCTAssertTrue(app.textFields["CPUHotspotLab.searchField"].waitForExistence(timeout: 4),
                      "Live search field should appear on CPU Hotspot Lab detail.")

        attachScreenshot(from: app, named: "signalLab-cpuHotspotLab-detail")
    }

    /// Thread Performance Checker Lab — scheme diagnostic guidance (`thread_performance_checker`).
    @MainActor
    func testScreenshot_threadPerformanceCheckerLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "thread_performance_checker", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.thread_performance_checker"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Thread Performance Checker Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Thread Performance Checker Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-threadPerformanceCheckerLab-detail")
    }

    @MainActor
    func testScreenshot_zombieObjectsLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "zombie_objects", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.zombie_objects"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Zombie Objects Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Zombie Objects Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-zombieObjectsLab-detail")
    }

    @MainActor
    func testScreenshot_threadSanitizerLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "thread_sanitizer", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.thread_sanitizer"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Thread Sanitizer Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Thread Sanitizer Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-threadSanitizerLab-detail")
    }

    @MainActor
    func testScreenshot_mallocStackLoggingLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "malloc_stack_logging", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.malloc_stack_logging"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Malloc Stack Logging Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Malloc Stack Logging Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-mallocStackLoggingLab-detail")
    }

    /// Heap Growth Lab — footprint vs retain cycle (`heap_growth`).
    @MainActor
    func testScreenshot_heapGrowthLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "heap_growth", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.heap_growth"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Heap Growth Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Heap Growth Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-heapGrowthLab-detail")
    }

    /// Deadlock Lab — main-queue self-deadlock (`deadlock`). Do not tap Run in Broken mode during automation.
    @MainActor
    func testScreenshot_deadlockLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "deadlock", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.deadlock"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Deadlock Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Deadlock Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-deadlockLab-detail")
    }

    @MainActor
    func testScreenshot_backgroundThreadUILabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "background_thread_ui", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.background_thread_ui"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Background Thread UI Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Background Thread UI Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-backgroundThreadUILab-detail")
    }

    @MainActor
    func testScreenshot_mainThreadIOLabDetail() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "main_thread_io", accessibilityDynamicType: false)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.main_thread_io"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8), "Main Thread I/O Lab detail root should appear.")
        XCTAssertTrue(app.navigationBars["Main Thread I/O Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-mainThreadIOLab-detail")
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
    func testScreenshot_exceptionBreakpointLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "break_on_failure", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.break_on_failure"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Exception Breakpoint Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-exceptionBreakpointLab-detail-accessibility")
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
    func testScreenshot_retainCycleLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "retain_cycle", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.retain_cycle"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Retain Cycle Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-retainCycleLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_hangLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "hang", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.hang"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Hang Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-hangLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_cpuHotspotLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "cpu_hotspot", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.cpu_hotspot"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["CPU Hotspot Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)
        XCTAssertTrue(app.textFields["CPUHotspotLab.searchField"].waitForExistence(timeout: 4))

        attachScreenshot(from: app, named: "signalLab-cpuHotspotLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_threadPerformanceCheckerLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "thread_performance_checker", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.thread_performance_checker"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Thread Performance Checker Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-threadPerformanceCheckerLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_zombieObjectsLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "zombie_objects", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.zombie_objects"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Zombie Objects Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-zombieObjectsLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_threadSanitizerLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "thread_sanitizer", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.thread_sanitizer"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Thread Sanitizer Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-threadSanitizerLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_mallocStackLoggingLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "malloc_stack_logging", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.malloc_stack_logging"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Malloc Stack Logging Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-mallocStackLoggingLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_heapGrowthLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "heap_growth", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.heap_growth"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Heap Growth Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-heapGrowthLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_deadlockLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "deadlock", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.deadlock"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Deadlock Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-deadlockLab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_backgroundThreadUILabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "background_thread_ui", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.background_thread_ui"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Background Thread UI Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-backgroundThreadUILab-detail-accessibility")
    }

    @MainActor
    func testScreenshot_mainThreadIOLabDetail_accessibilityText() throws {
        let app = XCUIApplication()
        launchScreenshotApp(app, labID: "main_thread_io", accessibilityDynamicType: true)

        let detailRoot = app.descendants(matching: .any)["SignalLab.detail.main_thread_io"]
        XCTAssertTrue(detailRoot.waitForExistence(timeout: 8))
        XCTAssertTrue(app.navigationBars["Main Thread I/O Lab"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["LabDetail.runScenario"].exists)

        attachScreenshot(from: app, named: "signalLab-mainThreadIOLab-detail-accessibility")
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
