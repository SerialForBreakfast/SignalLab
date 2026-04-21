//
//  BreakpointLabDiscountCalculator.swift
//  SignalLab
//
//  One readable discount calculation for Breakpoint Lab line-breakpoint practice.
//

import Foundation

enum BreakpointLabCustomerType: String, Sendable {
    case student

    var displayTitle: String {
        switch self {
        case .student: "Student"
        }
    }
}

struct BreakpointLabOrder: Equatable, Sendable {
    let customerType: BreakpointLabCustomerType
    let subtotal: Decimal
}

struct BreakpointLabDiscountResult: Equatable, Sendable {
    let customerType: BreakpointLabCustomerType
    let orderSubtotal: Decimal
    let expectedDiscountPercent: Int
    let appliedDiscountPercent: Int
    let expectedTotal: Decimal
    let actualTotal: Decimal

    var statusMessage: String {
        "\(customerType.displayTitle) order received only \(appliedDiscountPercent)% off. "
            + "Expected \(expectedDiscountPercent)%."
    }
}

enum BreakpointLabDiscountCalculator {
    nonisolated static let studentOrder = BreakpointLabOrder(customerType: .student, subtotal: 120)

    /// Calculates the visible student-order total. Set a line breakpoint in ``total(afterDiscountPercent:subtotal:)``.
    static func calculateStudentOrderTotal(order: BreakpointLabOrder = studentOrder) -> BreakpointLabDiscountResult {
        let customerType = order.customerType
        let orderSubtotal = order.subtotal
        let expectedDiscountPercent = BreakpointLabDiscountPolicy.expectedDiscountPercent(for: customerType)
        let appliedDiscountPercent = BreakpointLabDiscountPolicy.appliedDiscountPercent(for: customerType)
        let expectedTotal = BreakpointLabDiscountPolicy.expectedTotal(for: order)
        let actualTotal = total(afterDiscountPercent: appliedDiscountPercent, subtotal: orderSubtotal)

        return BreakpointLabDiscountResult(
            customerType: customerType,
            orderSubtotal: orderSubtotal,
            expectedDiscountPercent: expectedDiscountPercent,
            appliedDiscountPercent: appliedDiscountPercent,
            expectedTotal: expectedTotal,
            actualTotal: actualTotal
        )
    }

    static func currencyText(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        return "$\(String(format: "%.2f", number.doubleValue))"
    }

    private static func total(afterDiscountPercent discountPercent: Int, subtotal: Decimal) -> Decimal {
        let discountMultiplier = Decimal(100 - discountPercent) / Decimal(100)
        return subtotal * discountMultiplier
    }
}
