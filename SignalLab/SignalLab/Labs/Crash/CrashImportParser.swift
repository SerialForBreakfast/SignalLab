//
//  CrashImportParser.swift
//  SignalLab
//
//  Broken vs fixed parsing for the Crash Lab (unsafe assumptions vs validation).
//

import Foundation

/// Outcome of the validating import path used in Fixed mode.
struct CrashImportValidationResult: Equatable, Sendable {
    /// Records that contained a numeric `count` field.
    let lines: [CrashImportLine]
    /// Human-readable reasons for skipped or invalid rows.
    let skippedRecordMessages: [String]
}

/// JSON import helpers for Crash Lab.
enum CrashImportParser {
    /// Decodes loose dictionaries from JSON data.
    private static func jsonObjectArray(from data: Data) throws -> [[String: Any]] {
        let value = try JSONSerialization.jsonObject(with: data)
        guard let array = value as? [Any] else {
            throw CrashImportError.rootNotArray
        }
        var rows: [[String: Any]] = []
        rows.reserveCapacity(array.count)
        for element in array {
            guard let dict = element as? [String: Any] else {
                throw CrashImportError.elementNotObject
            }
            rows.append(dict)
        }
        return rows
    }

    // MARK: - Broken (intentionally unsafe)

    /// Typed row used by the broken import path — assumes `count` is always an integer.
    private struct CrashImportRow: Decodable {
        let id: String
        let name: String
        let count: Int
    }

    /// Decodes every row assuming the JSON matches the schema exactly.
    ///
    /// - Important: This path **crashes** when any row's `count` is not an integer — by design for Crash Lab.
    /// - Parameter jsonText: UTF-8 JSON array of objects as readable text so the debugger shows the payload.
    /// - Returns: Parsed lines; never returns if a row violates the schema.
    static func importLinesAssumingCompleteSchema(jsonText: String) -> [CrashImportLine] {
        let payloadJSONText = jsonText
        let payloadData = Data(payloadJSONText.utf8)
        let rows = try! JSONDecoder().decode([CrashImportRow].self, from: payloadData)
        return rows.map { CrashImportLine(id: $0.id, name: $0.name, count: $0.count) }
    }

    // MARK: - Fixed (validating)

    /// Parses rows, skipping malformed entries and collecting explanations.
    ///
    /// - Parameter data: UTF-8 JSON array of objects.
    /// - Returns: Successful lines plus messages describing skipped rows.
    static func importLinesValidatingRecords(data: Data) throws -> CrashImportValidationResult {
        let rows = try jsonObjectArray(from: data)
        var lines: [CrashImportLine] = []
        var skipped: [String] = []
        lines.reserveCapacity(rows.count)
        for dict in rows {
            guard let id = dict["id"] as? String, !id.isEmpty else {
                skipped.append("Skipped a row with missing or empty id.")
                continue
            }
            guard let name = dict["name"] as? String else {
                skipped.append("Skipped \(id): missing name.")
                continue
            }
            guard let countValue = dict["count"] else {
                skipped.append("Skipped \(id): missing count (malformed inventory row).")
                continue
            }
            guard let count = countValue as? Int else {
                skipped.append("Skipped \(id): count is not an integer.")
                continue
            }
            lines.append(CrashImportLine(id: id, name: name, count: count))
        }
        return CrashImportValidationResult(lines: lines, skippedRecordMessages: skipped)
    }
}

/// Errors surfaced only by the validating parser.
enum CrashImportError: Error, Equatable {
    case rootNotArray
    case elementNotObject
}
