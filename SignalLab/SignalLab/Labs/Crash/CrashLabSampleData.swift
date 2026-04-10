//
//  CrashLabSampleData.swift
//  SignalLab
//
//  Deterministic UTF-8 payload for Crash Lab; bundle resource overrides when present.
//

import Foundation

/// Provides the Crash Lab import fixture as ``Data``.
enum CrashLabSampleData {
    /// Inline copy of `crash_import_sample.json` so tests and previews stay deterministic if the bundle omits the file.
    static let embeddedJSONData: Data = """
    [
      {
        "id": "line-1",
        "name": "Resistor kit",
        "count": 12
      },
      {
        "id": "line-2",
        "name": "Malformed row (missing count)"
      }
    ]
    """.data(using: .utf8)!

    /// Loads bundled JSON when available, otherwise returns ``embeddedJSONData``.
    static func loadData() -> Data {
        if let url = Bundle.main.url(forResource: "crash_import_sample", withExtension: "json") {
            return (try? Data(contentsOf: url)) ?? embeddedJSONData
        }
        return embeddedJSONData
    }
}
