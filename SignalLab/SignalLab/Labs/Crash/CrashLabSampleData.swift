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
    static let embeddedJSONString: String = """
    [
      {
        "id": "line-1",
        "name": "Resistor kit",
        "count": 12
      },
      {
        "id": "line-2",
        "name": "Soldering iron stand",
        "count": "three"
      }
    ]
    """

    /// Inline JSON as UTF-8 data.
    static let embeddedJSONData: Data = Data(embeddedJSONString.utf8)

    /// Loads bundled JSON text when available, otherwise returns ``embeddedJSONString``.
    static func loadJSONString() -> String {
        if let url = Bundle.main.url(forResource: "crash_import_sample", withExtension: "json") {
            return (try? String(contentsOf: url, encoding: .utf8)) ?? embeddedJSONString
        }
        return embeddedJSONString
    }

    /// Loads bundled JSON when available, otherwise returns ``embeddedJSONData``.
    static func loadData() -> Data {
        Data(loadJSONString().utf8)
    }
}
