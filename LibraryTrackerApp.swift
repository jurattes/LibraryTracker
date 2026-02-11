//
//  LibraryTrackerApp.swift
//  LibraryTracker
//
//  Created by Justin Pescador on 2026-02-10.
//

import SwiftUI
import CoreData

@main
struct LibraryTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let ctx = persistenceController.container.viewContext
            ContentView()
                .environment(\.managedObjectContext, ctx)
                .environmentObject(LibraryHolder(ctx))
        }
    }
}
