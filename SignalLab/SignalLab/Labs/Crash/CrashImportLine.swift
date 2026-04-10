//
//  CrashImportLine.swift
//  SignalLab
//
//  Parsed inventory line for the Crash Lab import scenario.
//

import Foundation

/// One successfully parsed row from the Crash Lab sample import file.
struct CrashImportLine: Equatable, Hashable, Sendable {
    /// Stable identifier from the source payload.
    let id: String
    /// Human-readable description of the part or bundle.
    let name: String
    /// Quantity on hand; required for a valid record in this lab.
    let count: Int
}
