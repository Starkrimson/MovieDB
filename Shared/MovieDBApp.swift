//
//  MovieDBApp.swift
//  Shared
//
//  Created by allie on 30/6/2022.
//

import SwiftUI
import SwiftData

@main
struct MovieDBApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.shared.modelContainer)
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
