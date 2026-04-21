//
//  BreakpointLabFilter.swift
//  SignalLab
//
//  Central filter pipeline for Breakpoint Lab — place line / conditional breakpoints here.
//

import Foundation

/// Applies combined **name search** and **category** filtering to the sample catalog.
///
/// Breakpoint Lab intentionally routes all filtering through ``applyCatalogFilter(items:normalizedQuery:category:mode:)``
/// so learners can set breakpoints in one predictable function.
enum BreakpointLabFilter {
    /// Normalizes user text for comparisons (trim + fold case via standard string APIs).
    static func normalizeQuery(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Applies category + name filtering according to broken vs fixed semantics.
    ///
    /// - Parameters:
    ///   - items: Full sample catalog.
    ///   - normalizedQuery: Already trimmed query; empty means "no name constraint".
    ///   - category: When non-`nil`, restrict to this category.
    ///   - mode: Broken ignores the name query whenever a category is selected; Fixed always intersects both predicates.
    static func applyCatalogFilter(
        items: [BreakpointLabItem],
        normalizedQuery: String,
        category: BreakpointLabCategory?,
        mode: LabImplementationMode
    ) -> [BreakpointLabItem] {
        switch mode {
        case .broken:
            applyBroken(items: items, normalizedQuery: normalizedQuery, category: category)
        case .fixed:
            applyFixed(items: items, normalizedQuery: normalizedQuery, category: category)
        }
    }

    // MARK: - Broken (intentional logic bug)

    /// **Bug:** When a category is chosen, results include **every** item in that category and the name query is ignored.
    private static func applyBroken(
        items: [BreakpointLabItem],
        normalizedQuery: String,
        category: BreakpointLabCategory?
    ) -> [BreakpointLabItem] {
        if let category {
            return items.filter { $0.category == category }
        }
        return filterByName(items: items, normalizedQuery: normalizedQuery)
    }

    // MARK: - Fixed

    /// Applies category (if any) **and** name substring match (if non-empty).
    private static func applyFixed(
        items: [BreakpointLabItem],
        normalizedQuery: String,
        category: BreakpointLabCategory?
    ) -> [BreakpointLabItem] {
        var result = items
        if let category {
            result = result.filter { $0.category == category }
        }
        return filterByName(items: result, normalizedQuery: normalizedQuery)
    }

    private static func filterByName(items: [BreakpointLabItem], normalizedQuery: String) -> [BreakpointLabItem] {
        guard !normalizedQuery.isEmpty else { return items }
        return items.filter { $0.name.localizedStandardContains(normalizedQuery) }
    }
}
