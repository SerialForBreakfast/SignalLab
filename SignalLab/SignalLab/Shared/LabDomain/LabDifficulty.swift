//
//  LabDifficulty.swift
//  SignalLab
//
//  Communicates expected learner experience level for catalog sorting and badges.
//

import Foundation

/// Relative difficulty used for catalog presentation only (not a formal assessment).
enum LabDifficulty: String, CaseIterable, Sendable, Comparable {
    case beginner
    case intermediate

    var displayTitle: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        }
    }

    /// Stable ordering: easier labs first.
    private var sortRank: Int {
        switch self {
        case .beginner: 0
        case .intermediate: 1
        }
    }

    static func < (lhs: LabDifficulty, rhs: LabDifficulty) -> Bool {
        lhs.sortRank < rhs.sortRank
    }
}
