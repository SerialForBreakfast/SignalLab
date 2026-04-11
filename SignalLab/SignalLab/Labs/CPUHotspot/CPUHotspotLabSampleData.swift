//
//  CPUHotspotLabSampleData.swift
//  SignalLab
//
//  Deterministic 500-item diagnostic event catalog for CPU Hotspot Lab.
//

import Foundation

/// Generates the fixed event catalog used by CPU Hotspot Lab.
///
/// 500 items across 5 categories (100 per category), with 20 base event names per category
/// repeated five times with numeric suffixes. Timestamps are spaced 45 seconds apart going
/// backward from a fixed reference point so the dataset is fully deterministic across runs.
///
/// The dataset is large enough that the per-item `DateFormatter` creation in Broken mode
/// produces a measurable hotspot in a Time Profiler trace.
enum CPUHotspotLabSampleData {

    /// All 500 diagnostic events, pre-generated at app launch.
    static let items: [CPUHotspotLabItem] = makeItems()

    // MARK: - Generation

    private static func makeItems() -> [CPUHotspotLabItem] {
        // Formatter created once here — only for initial data generation, not for per-search use.
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // Fixed reference: 2023-11-14 09:33:20 UTC — keeps output stable across locales.
        let base = Date(timeIntervalSince1970: 1_700_000_000)

        var result = [CPUHotspotLabItem]()
        result.reserveCapacity(500)

        for i in 0..<500 {
            let catIndex = i % categoryNames.count
            let nameList = categoryNames[catIndex]
            let nameIndex = (i / categoryNames.count) % nameList.count
            let suffix = (i / (categoryNames.count * nameList.count))
            let baseName = nameList[nameIndex]
            let name = suffix == 0 ? baseName : "\(baseName)_\(suffix)"

            let priority = (i % 5) + 1
            let timestamp = base.addingTimeInterval(Double(i) * -45.0)
            let formatted = formatter.string(from: timestamp)

            result.append(
                CPUHotspotLabItem(
                    name: name,
                    category: categories[catIndex],
                    priority: priority,
                    timestamp: timestamp,
                    formattedTimestamp: formatted
                )
            )
        }
        return result
    }

    // MARK: - Name tables

    private static let categories = ["Memory", "Network", "CPU", "I/O", "System"]

    /// 20 base event names per category.  5 categories × 20 names × 5 repetitions = 500 items.
    private static let categoryNames: [[String]] = [
        // Memory
        [
            "MemoryWarning", "AllocationSpike", "HeapGrowth", "ObjectRetained", "LeakDetected",
            "PageFault", "VMPressure", "BufferOverrun", "StackGrowth", "ArenaExpansion",
            "ZoneAllocFail", "CompactorRun", "SwapActivity", "ResidentSetGrowth", "SparseAlloc",
            "LargeObjectAlloc", "ZeroFillPage", "CopyOnWrite", "EvictionNotice", "WiredMemoryHigh",
        ],
        // Network
        [
            "RequestTimeout", "ConnectionReset", "TLSHandshakeFailed", "DNSResolutionSlow", "ResponseTruncated",
            "PacketLoss", "RetryExhausted", "SocketClosed", "BandwidthThrottled", "CacheBypass",
            "RedirectLoop", "HostUnreachable", "ProxyAuthFailed", "HttpError", "SessionExpired",
            "CertValidationError", "PortScanDetected", "LatencySpike", "ContentDecodeFailed", "NetworkTypeChange",
        ],
        // CPU
        [
            "HotspotDetected", "HighCPUUsage", "SpinlockContention", "ContextSwitchStorm", "ThermalThrottle",
            "CoreStarvation", "SchedulerDelay", "InstructionCacheMiss", "BranchMisprediction", "VectorUnitStall",
            "JITRecompile", "CompilerTier", "BackgroundPressure", "WorkerThrottled", "AsyncFlood",
            "TaskQueueFull", "DispatchOvercommit", "MainThreadBusy", "IdleCoreWaste", "CPUSamplingEvent",
        ],
        // I/O
        [
            "DiskLatencySpike", "FileHandleLeak", "ReadAheadMiss", "WriteStall", "DirectoryEnumSlow",
            "FSNotificationBacklog", "DiskPressure", "FileDescriptorLimit", "NVMeSaturation", "JournalFlush",
            "MetadataUpdate", "DataSyncDelay", "BufferFlush", "CacheEvict", "SectorError",
            "ReadRetry", "WriteVerify", "StorageContention", "MountSlowdown", "VFSCallDelay",
        ],
        // System
        [
            "WatchdogTimeout", "ProcessSuspended", "JetsamKill", "SandboxDenial", "PortExhaustion",
            "MachPortLeak", "SignalReceived", "ExceptionHandlerFired", "KernelExtLoad", "SysctlQuery",
            "DyldLibLoad", "ObjCMethodLookup", "SwiftRuntimeCall", "LaunchConstraint", "PrivacyCheck",
            "EntitlementDenied", "SecurityViolation", "SIPProtection", "SystemIntegrityCheck", "BootKargo",
        ],
    ]
}
