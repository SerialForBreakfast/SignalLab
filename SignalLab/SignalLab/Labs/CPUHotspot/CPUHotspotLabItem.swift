//
//  CPUHotspotLabItem.swift
//  SignalLab
//
//  Diagnostic event model for CPU Hotspot Lab.
//

import Foundation

/// A single diagnostic event in the CPU Hotspot Lab catalog.
///
/// Two fields exist specifically to support the Fixed mode search path:
/// - ``searchKey`` — pre-computed lowercased composite of name, category, and timestamp; avoids
///   per-call `lowercased()` on every item.
/// - ``formattedTimestamp`` — formatted once at data-load time; avoids allocating a `DateFormatter`
///   on every search call (the primary hotspot in Broken mode).
struct CPUHotspotLabItem: Identifiable, Sendable {
    let id: UUID
    let name: String
    let category: String
    /// Diagnostic severity: 1 (low) … 5 (critical).
    let priority: Int
    let timestamp: Date

    // MARK: - Pre-computed (Fixed mode)

    /// Formatted representation of ``timestamp`` (e.g., `"Nov 14, 09:30:00"`).
    ///
    /// **Fixed mode** reads this field directly. **Broken mode** creates a fresh `DateFormatter` per
    /// item per search call instead — that allocation is the dominant `DateFormatter`-creation hotspot.
    let formattedTimestamp: String

    /// Lowercased composite of name, category, and formatted timestamp separated by spaces.
    ///
    /// **Fixed mode** calls `contains` on this field once per item per search. **Broken mode**
    /// calls `lowercased()` on `name` and `category` individually on every filter pass instead.
    let searchKey: String

    init(name: String, category: String, priority: Int, timestamp: Date, formattedTimestamp: String) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.priority = priority
        self.timestamp = timestamp
        self.formattedTimestamp = formattedTimestamp
        self.searchKey = "\(name.lowercased()) \(category.lowercased()) \(formattedTimestamp.lowercased())"
    }
}
