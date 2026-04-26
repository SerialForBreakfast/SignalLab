//
//  LabScenario.swift
//  SignalLab
//
//  Static metadata describing one lab; behavior is supplied by a runner and future ``Labs`` modules.
//

import Foundation

/// Describes a single lab for the catalog and detail UI.
///
/// All fields are immutable value data suitable for sharing across the main actor and tests.
struct LabScenario: Identifiable, Equatable, Hashable, Sendable {
    /// Stable slug used for navigation and tests (for example, `"crash"`).
    let id: String
    /// Display title on home and detail screens.
    let title: String
    /// One- or two-sentence summary for the catalog row.
    let summary: String
    let category: LabCategory
    let difficulty: LabDifficulty
    /// Primary learning outcomes shown on the detail screen.
    let learningGoals: [String]
    /// How to reproduce the symptom quickly and consistently.
    let reproductionSteps: [String]
    /// Progressive hints; should not fully disclose the root cause.
    let hints: [String]
    /// Tooling suggestions (Xcode, Instruments templates, diagnostics).
    let toolRecommendations: [String]
    let investigationGuide: InvestigationGuide
    /// Deterministic ordering in the catalog (lower appears earlier).
    let catalogSortIndex: Int
}
