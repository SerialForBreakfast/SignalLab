//
//  BreakpointLabSampleCatalog.swift
//  SignalLab
//
//  Deterministic catalog backing the Breakpoint Lab UI.
//

import Foundation

/// Built-in items for Breakpoint Lab (local-only, no network).
enum BreakpointLabSampleCatalog {
    /// Default inventory shown in the lab.
    static let items: [BreakpointLabItem] = [
        BreakpointLabItem(id: "1", name: "Swift Debugging Field Guide", category: .books),
        BreakpointLabItem(id: "2", name: "USB-C Hub", category: .electronics),
        BreakpointLabItem(id: "3", name: "Desk LED Lamp", category: .office),
        BreakpointLabItem(id: "4", name: "Thinking in Systems", category: .books),
        BreakpointLabItem(id: "5", name: "Noise Cancelling Headphones", category: .electronics),
        BreakpointLabItem(id: "6", name: "Mechanical Keyboard", category: .electronics),
    ]
}
