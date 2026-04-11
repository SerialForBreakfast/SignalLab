//
//  CPUHotspotLabSearch.swift
//  SignalLab
//
//  Broken and fixed search implementations for CPU Hotspot Lab.
//
//  TEACHING NOTE — Three hotspots in Broken mode (all visible in a Time Profiler trace):
//
//  1. Full sort on every call — `items.sorted(by:)` runs on all 500 items for each keystroke,
//     even though the relative order of items never changes between queries.
//
//  2. `DateFormatter` allocation per item — `DateFormatter()` is a heavyweight Objective-C object.
//     Creating one inside the `filter` closure means 500 allocations per keystroke. Time Profiler
//     shows this as a large `DateFormatter.init` / `NSDateFormatter.init` self-time spike.
//
//  3. `lowercased()` per item per call — rather than reading a pre-computed key, Broken mode
//     calls `.lowercased()` on both `item.name` and `item.category` for every item on every search.
//
//  Fixed mode eliminates all three:
//  - `sortedItems` is pre-sorted once at runner init time.
//  - `item.formattedTimestamp` is formatted once at data-load time.
//  - `item.searchKey` is a pre-lowercased composite; a single `contains` replaces three per-call ops.

import Foundation

/// Central search pipeline for CPU Hotspot Lab — place Time Profiler here to see the hot path.
///
/// Route all filtering through ``search(items:sortedItems:query:mode:)`` so learners can add
/// a line breakpoint or profile both implementations from one entry point.
enum CPUHotspotLabSearch {

    // MARK: - Dispatch

    /// Applies Broken or Fixed search depending on ``LabImplementationMode``.
    ///
    /// - Parameters:
    ///   - items: Unsorted full catalog — used only by Broken mode (which re-sorts per call).
    ///   - sortedItems: Pre-sorted catalog — used only by Fixed mode.
    ///   - query: Raw text from the search field; normalization is applied inside each path.
    ///   - mode: Selects which implementation runs.
    static func search(
        items: [CPUHotspotLabItem],
        sortedItems: [CPUHotspotLabItem],
        query: String,
        mode: LabImplementationMode
    ) -> [CPUHotspotLabItem] {
        switch mode {
        case .broken: applyBroken(items: items, query: query)
        case .fixed:  applyFixed(sortedItems: sortedItems, query: query)
        }
    }

    // MARK: - Broken (three deliberate hotspots)

    /// Filters events with three compounding performance problems.
    ///
    /// Set a Time Profiler breakpoint here to catch all three hotspots in one frame.
    static func applyBroken(items: [CPUHotspotLabItem], query: String) -> [CPUHotspotLabItem] {
        // Hotspot 1: sort the full 500-item catalog on every keystroke.
        // The relative order never changes between queries, so this work is always redundant.
        let sorted = items.sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
            return lhs.timestamp > rhs.timestamp
        }

        let normalized = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return sorted }

        return sorted.filter { item in
            // Hotspot 2: allocate a DateFormatter per item.
            // DateFormatter initialization is a heavyweight Objective-C operation. Creating one
            // inside the filter closure means one allocation per item per keystroke.
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let dateString = formatter.string(from: item.timestamp)

            // Hotspot 3: lowercased() called per item per search instead of using a pre-computed key.
            let nameMatch     = item.name.lowercased().contains(normalized)
            let categoryMatch = item.category.lowercased().contains(normalized)
            let dateMatch     = dateString.lowercased().contains(normalized)

            return nameMatch || categoryMatch || dateMatch
        }
    }

    // MARK: - Fixed (pre-sorted + pre-computed keys)

    /// Filters events using a pre-sorted catalog and pre-computed search keys.
    ///
    /// No sorting, no formatter allocation, no per-call lowercasing — all three Broken-mode
    /// hotspots are eliminated by work done once at data-load time.
    static func applyFixed(sortedItems: [CPUHotspotLabItem], query: String) -> [CPUHotspotLabItem] {
        let normalized = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return sortedItems }
        // `searchKey` = lowercased name + category + formatted timestamp, joined by spaces.
        // A single `contains` replaces three separate per-call string operations.
        return sortedItems.filter { $0.searchKey.contains(normalized) }
    }
}
