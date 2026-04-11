//
//  LabGuidedDiagnosticLayout.swift
//  SignalLab
//
//  Shared card row for scheme-diagnostic guided labs (Thread Performance, Zombies, TSan, Malloc).
//

import SwiftUI

enum LabGuidedDiagnosticLayout {
    @ViewBuilder
    static func row(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(body)
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SignalLabTheme.horizontalPadding / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
