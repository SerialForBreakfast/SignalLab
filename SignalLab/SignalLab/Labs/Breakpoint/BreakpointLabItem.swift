//
//  BreakpointLabItem.swift
//  SignalLab
//
//  Sample catalog row for Breakpoint Lab search/filter exercises.
//

import Foundation

/// One row in the Breakpoint Lab sample inventory.
struct BreakpointLabItem: Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let name: String
    let category: BreakpointLabCategory
}
