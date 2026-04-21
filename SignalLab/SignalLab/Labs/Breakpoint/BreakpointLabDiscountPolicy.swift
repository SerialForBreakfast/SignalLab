//
//  BreakpointLabDiscountPolicy.swift
//  SignalLab
//
//  Discount rules used by Breakpoint Lab.
//

import Foundation

enum BreakpointLabDiscountPolicy {
    static func expectedDiscountPercent(for customerType: BreakpointLabCustomerType) -> Int {
        switch customerType {
        case .student: 20
        }
    }

    static func appliedDiscountPercent(for customerType: BreakpointLabCustomerType) -> Int {
        switch customerType {
        case .student: 5
        }
    }

    static func expectedTotal(for order: BreakpointLabOrder) -> Decimal {
        let expectedDiscountPercent = expectedDiscountPercent(for: order.customerType)
        let discountMultiplier = Decimal(100 - expectedDiscountPercent) / Decimal(100)
        return order.subtotal * discountMultiplier
    }
}
