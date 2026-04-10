//
//  SignalLabTheme.swift
//  SignalLab
//
//  Minimal design tokens for a dark, tool-like shell (Tasks X1).
//

import SwiftUI

/// Shared spacing and colors for catalog and lab detail screens.
enum SignalLabTheme {
    /// Standard horizontal padding for readable line length on phones.
    static let horizontalPadding: CGFloat = 20
    /// Vertical rhythm between major sections on the detail screen.
    static let sectionSpacing: CGFloat = 20
    /// Tighter stack spacing inside a section.
    static let itemSpacing: CGFloat = 8

    /// Primary background (dark-forward).
    static let background = Color(red: 0.07, green: 0.08, blue: 0.10)
    /// Elevated card / grouped content surface.
    static let cardBackground = Color(red: 0.11, green: 0.12, blue: 0.15)
    /// Secondary text on dark surfaces.
    static let secondaryText = Color(red: 0.65, green: 0.70, blue: 0.78)
    /// Accent for interactive accents and key labels.
    static let accent = Color(red: 0.35, green: 0.55, blue: 0.95)
    /// Semantic warning / broken mode emphasis.
    static let warning = Color(red: 0.95, green: 0.55, blue: 0.35)
    /// Semantic positive / fixed mode emphasis.
    static let success = Color(red: 0.40, green: 0.78, blue: 0.55)
}
