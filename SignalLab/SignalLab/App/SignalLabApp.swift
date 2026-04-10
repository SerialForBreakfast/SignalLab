//
//  SignalLabApp.swift
//  SignalLab
//
//  Created by Joseph McCraw on 4/9/26.
//

import OSLog
import SwiftUI

@main
struct SignalLabApp: App {
    init() {
        SignalLabLog.appLifecycle.notice("SignalLab launching—subsystem=\(SignalLabLog.subsystemForDiagnostics)")
    }

    var body: some Scene {
        WindowGroup {
            iOSLabCatalogView()
        }
    }
}
