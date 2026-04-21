//
//  CrashImportParserTests.swift
//  SignalLabTests
//
//  Covers validating import behavior and malformed-row handling (Crash Lab).
//

import Foundation
import Testing
@testable import SignalLab

struct CrashImportParserTests {
    @Test func importLinesValidatingRecords_keepsValidRowsAndSkipsWrongType() throws {
        let result = try CrashImportParser.importLinesValidatingRecords(data: CrashLabSampleData.embeddedJSONData)
        #expect(result.lines.count == 1)
        #expect(result.lines.first?.id == "line-1")
        #expect(result.lines.first?.count == 12)
        #expect(result.skippedRecordMessages.count == 1)
        let message = try #require(result.skippedRecordMessages.first)
        #expect(message.contains("line-2"))
        #expect(message.contains("not an integer"))
    }

    @Test func importLinesValidatingRecords_rejectsNonArrayRoot() {
        let data = Data("{}".utf8)
        #expect(throws: CrashImportError.self) {
            try CrashImportParser.importLinesValidatingRecords(data: data)
        }
    }
}
