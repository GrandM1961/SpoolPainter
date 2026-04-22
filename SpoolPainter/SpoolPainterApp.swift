//
//  SpoolPainterApp.swift
//  SpoolPainter
//
//  Created by Hans van Schooten on 12/03/2026.
//

import SwiftUI

@main
struct SpoolPainterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()  // ← DIT moet ContentView zijn!
                .environment(\.scenePhase, .active)
                .preferredColorScheme(.dark)
        }
    }
}
