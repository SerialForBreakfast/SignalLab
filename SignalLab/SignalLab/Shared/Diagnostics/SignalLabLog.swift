//
//  SignalLabLog.swift
//  SignalLab
//
//  Unified `os.Logger` categories for Console.app / `log stream --predicate`.
//

import OSLog

/// Shared logging entry points keyed by **category** (filter in Console with the subsystem + category).
///
/// - **Subsystem:** `Bundle.main.bundleIdentifier` (falls back to `com.showblender.SignalLab` in tests).
/// - **Categories:** `AppLifecycle`, `Catalog`, `LabDetail`, `ScenarioRunner` (stub labs), and per-lab categories (`CrashLab`, `ExceptionBreakpointLab`, `BreakpointLab`, `RetainCycleLab`, `HangLab`, `CPUHotspotLab`, `ThreadPerformanceCheckerLab`, `ZombieObjectsLab`, `ThreadSanitizerLab`, `MallocStackLoggingLab`, `HeapGrowthLab`, `DeadlockLab`, `BackgroundThreadUILab`, `MainThreadIOLab`).
///
/// Example CLI filter:
/// ```text
/// log stream --predicate 'subsystem == "com.showblender.SignalLab" && category == "CrashLab"'
/// ```
enum SignalLabLog {
    private static let subsystem: String = Bundle.main.bundleIdentifier ?? "com.showblender.SignalLab"

    /// Bundle identifier (or test fallback) used as the `os.Logger` subsystem—filter on this string in Console.
    static var subsystemForDiagnostics: String { subsystem }

    /// App launch and scene lifecycle.
    static let appLifecycle = Logger(subsystem: subsystem, category: "AppLifecycle")

    /// Lab catalog list and navigation to a scenario.
    static let catalog = Logger(subsystem: subsystem, category: "Catalog")

    /// Shared lab detail scaffold (any scenario).
    static let labDetail = Logger(subsystem: subsystem, category: "LabDetail")

    /// Default stub runner used by labs without custom behavior yet.
    static let scenarioRunner = Logger(subsystem: subsystem, category: "ScenarioRunner")

    static let crashLab = Logger(subsystem: subsystem, category: "CrashLab")

    /// Exception Breakpoint Lab (`break_on_failure`) and related UI.
    static let exceptionBreakpointLab = Logger(subsystem: subsystem, category: "ExceptionBreakpointLab")

    static let breakpointLab = Logger(subsystem: subsystem, category: "BreakpointLab")
    static let retainCycleLab = Logger(subsystem: subsystem, category: "RetainCycleLab")
    static let hangLab = Logger(subsystem: subsystem, category: "HangLab")
    static let cpuHotspotLab = Logger(subsystem: subsystem, category: "CPUHotspotLab")

    /// Thread Performance Checker Lab (`thread_performance_checker`) — scheme diagnostic guidance.
    static let threadPerformanceCheckerLab = Logger(subsystem: subsystem, category: "ThreadPerformanceCheckerLab")

    /// Zombie Objects Lab (`zombie_objects`) — scheme diagnostic guidance.
    static let zombieObjectsLab = Logger(subsystem: subsystem, category: "ZombieObjectsLab")

    /// Thread Sanitizer Lab (`thread_sanitizer`) — scheme diagnostic guidance.
    static let threadSanitizerLab = Logger(subsystem: subsystem, category: "ThreadSanitizerLab")

    /// Malloc Stack Logging Lab (`malloc_stack_logging`) — scheme diagnostic guidance.
    static let mallocStackLoggingLab = Logger(subsystem: subsystem, category: "MallocStackLoggingLab")

    /// Heap Growth Lab (`heap_growth`) — Phase 2 footprint vs retain cycle contrast.
    static let heapGrowthLab = Logger(subsystem: subsystem, category: "HeapGrowthLab")

    /// Deadlock Lab (`deadlock`) — Phase 2 main-queue self-deadlock.
    static let deadlockLab = Logger(subsystem: subsystem, category: "DeadlockLab")

    /// Background Thread UI Lab (`background_thread_ui`) — Phase 2 notification threading.
    static let backgroundThreadUILab = Logger(subsystem: subsystem, category: "BackgroundThreadUILab")

    /// Main Thread I/O Lab (`main_thread_io`) — Phase 2 synchronous read on main vs detached read.
    static let mainThreadIOLab = Logger(subsystem: subsystem, category: "MainThreadIOLab")
}
