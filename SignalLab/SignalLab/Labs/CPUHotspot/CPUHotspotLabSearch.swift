//
//  CPUHotspotLabSearch.swift
//  SignalLab
//
//  Search implementation for CPU Hotspot Lab — three deliberate hotspots visible in Time Profiler.
//
//  TEACHING NOTE — Three hotspots visible in a Time Profiler trace:
//
//  1. Full sort on every call — `items.sorted(by:)` runs on all 500 items for each keystroke,
//     even though the relative order of items never changes between queries.
//
//  2. `DateFormatter` allocation per item — `DateFormatter()` is a heavyweight Objective-C object.
//     Creating one inside the `filter` closure means 500 allocations per keystroke. Time Profiler
//     shows this as a large `DateFormatter.init` / `NSDateFormatter.init` self-time spike.
//
//  3. `lowercased()` per item per call — rather than reading a pre-computed key, this path
//     calls `.lowercased()` on both `item.name` and `item.category` for every item on every search.
//
//  The optimized path (applyFixed) eliminates all three:
//  - `sortedItems` would be pre-sorted once at init time.
//  - `item.formattedTimestamp` is formatted once at data-load time.
//  - `item.searchKey` is a pre-lowercased composite; a single `contains` replaces three per-call ops.

import Foundation

/// Central search pipeline for CPU Hotspot Lab — place Time Profiler here to see the hot path.
///
/// Route all filtering through ``search(items:query:)`` so learners can add a line breakpoint
/// or profile from one entry point.
enum CPUHotspotLabSearch {

    // MARK: - Entry point

    /// Runs the search with deliberate hotspots.
    ///
    /// - Parameters:
    ///   - items: Unsorted full catalog — re-sorted on every call (Hotspot 1).
    ///   - query: Raw text from the search field; normalization is applied inside.
    static func search(
        items: [CPUHotspotLabItem],
        query: String
    ) -> [CPUHotspotLabItem] {
        applyBroken(items: items, query: query)
    }

    // MARK: - Intentionally slow path (three deliberate hotspots)

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

    // MARK: - Optimized path (documents the fix; not used in the lab)

    /// Filters events using a pre-sorted catalog and pre-computed search keys.
    ///
    /// No sorting, no formatter allocation, no per-call lowercasing — all three hotspots above
    /// are eliminated by work done once at data-load time.
    /// This method is kept as a reference showing the intended optimization.
    static func applyFixed(sortedItems: [CPUHotspotLabItem], query: String) -> [CPUHotspotLabItem] {
        let normalized = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return sortedItems }
        // `searchKey` = lowercased name + category + formatted timestamp, joined by spaces.
        // A single `contains` replaces three separate per-call string operations.
        return sortedItems.filter { $0.searchKey.contains(normalized) }
    }
}
