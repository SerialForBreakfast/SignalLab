//
//  InvestigationGuide.swift
//  SignalLab
//
//  Recommended tooling and steps for a lab, shown on the detail scaffold.
//

import Foundation

/// Debugging workflow hints for a single lab (text-first; scenario code lives under ``Labs`` later).
struct InvestigationGuide: Equatable, Hashable, Sendable {
    /// Suggested first tool or Xcode surface (for example, Exception Breakpoint).
    var recommendedFirstTool: String
    /// Ordered steps the learner can follow during investigation.
    var steps: [String]
    /// Short checks that confirm the learner validated their understanding.
    var validationChecklist: [String]
}
