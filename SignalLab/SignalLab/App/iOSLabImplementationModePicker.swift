//
//  iOSLabImplementationModePicker.swift
//  SignalLab
//
//  Reusable broken/fixed control for the lab detail scaffold (M0.2.3).
//

import OSLog
import SwiftUI

/// Segmented control for selecting broken vs fixed implementations when supported.
struct iOSLabImplementationModePicker: View {
    @Binding var mode: LabImplementationMode
    let supportsBrokenMode: Bool
    let supportsFixedMode: Bool

    var body: some View {
        if supportsBrokenMode || supportsFixedMode {
            VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
                Text("Implementation")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityAddTraits(.isHeader)
                if supportsBrokenMode, supportsFixedMode {
                    Picker("Implementation", selection: $mode) {
                        Text(LabImplementationMode.broken.displayTitle).tag(LabImplementationMode.broken)
                        Text(LabImplementationMode.fixed.displayTitle).tag(LabImplementationMode.fixed)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("LabDetail.implementationPicker")
                    .accessibilityHint("Broken shows the teaching defect; Fixed shows the corrected behavior.")
                    .onChange(of: mode) { _, newValue in
                        SignalLabLog.labDetail.debug("Implementation mode → \(newValue.rawValue, privacy: .public)")
                    }
                } else if supportsBrokenMode {
                    Label("Broken mode only", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(SignalLabTheme.warning)
                        .font(.subheadline)
                } else if supportsFixedMode {
                    Label("Fixed mode only", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(SignalLabTheme.success)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var mode = LabImplementationMode.broken
    return iOSLabImplementationModePicker(
        mode: $mode,
        supportsBrokenMode: true,
        supportsFixedMode: true
    )
    .padding()
    .background(SignalLabTheme.background)
}
