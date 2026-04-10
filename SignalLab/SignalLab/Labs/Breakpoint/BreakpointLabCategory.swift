//
//  BreakpointLabCategory.swift
//  SignalLab
//
//  Product category axis for the Breakpoint Lab catalog filter.
//

import Foundation

/// Category used together with the name search in Breakpoint Lab.
enum BreakpointLabCategory: String, CaseIterable, Sendable, Identifiable {
    case books
    case electronics
    case office

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .books: "Books"
        case .electronics: "Electronics"
        case .office: "Office"
        }
    }
}
