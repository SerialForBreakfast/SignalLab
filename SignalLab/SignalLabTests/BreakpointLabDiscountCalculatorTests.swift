//
//  BreakpointLabDiscountCalculatorTests.swift
//  SignalLabTests
//
//  Business result for the Breakpoint Lab discount scenario.
//

import Foundation
import Testing
@testable import SignalLab

struct BreakpointLabDiscountCalculatorTests {
    @Test func studentOrder_appliesIntentionallyWrongDiscount() {
        let result = BreakpointLabDiscountCalculator.calculateStudentOrderTotal()

        #expect(result.customerType == .student)
        #expect(result.orderSubtotal == 120)
        #expect(result.expectedDiscountPercent == 20)
        #expect(result.appliedDiscountPercent == 5)
        #expect(result.expectedTotal == 96)
        #expect(result.actualTotal == 114)
        #expect(result.statusMessage == "Student order received only 5% off. Expected 20%.")
    }
}
