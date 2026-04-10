//
//  LabImplementationMode.swift
//  SignalLab
//
//  Selects intentionally broken vs corrected scenario implementations for comparison.
//

import Foundation

/// Which implementation variant is active for a lab scenario.
enum LabImplementationMode: String, CaseIterable, Sendable, Identifiable {
    case broken
    case fixed

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .broken: "Broken"
        case .fixed: "Fixed"
        }
    }
}
