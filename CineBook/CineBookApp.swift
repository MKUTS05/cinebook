//
//  CineBookApp.swift
//  CineBook
//
//  Created by MK UNI on 5/5/2026.
//

import CoreData
import SwiftUI

@main
struct CineBookApp: App {
    /// Single Core Data stack shared across the whole app.
    /// Touching `.shared` triggers store loading and first-launch seeding.
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
