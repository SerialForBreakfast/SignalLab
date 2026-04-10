//
//  LabCategory.swift
//  SignalLab
//
//  Groups labs for catalog display and curriculum navigation.
//

import Foundation

/// High-level curriculum bucket for a debugging lab.
///
/// Categories align with the MVP roadmap (crash, logic breakpoints, memory, hangs, performance).
enum LabCategory: String, CaseIterable, Sendable, Identifiable {
    case crash
    case breakpoint
    case memory
    case hang
    case performance

    var id: String { rawValue }

    /// Short label shown in list rows and badges.
    var displayTitle: String {
        switch self {
        case .crash: "Crash"
        case .breakpoint: "Breakpoint"
        case .memory: "Memory"
        case .hang: "Hang"
        case .performance: "Performance"
        }
    }
}
