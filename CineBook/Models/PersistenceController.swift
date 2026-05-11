//
//  PersistenceController.swift
//  CineBook
//
//  Sets up the Core Data stack for the app.
//

import CoreData

struct PersistenceController {

    /// Shared instance used by the running app.
    /// @MainActor ensures it is only initialised on the main thread, which is
    /// required because init touches viewContext and calls DataSeeder on it.
    @MainActor
    static let shared = PersistenceController()

    /// In-memory instance pre-populated with seed data, intended for SwiftUI previews.
    @MainActor
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CineBook")

        if inMemory {
            // Route the store to /dev/null so nothing is persisted between launches.
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In a real app, log this and surface a recoverable error to the user
                // instead of crashing. We fail fast here so problems are caught in dev.
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Seed initial content the first time the app runs (or anytime the store is empty).
        DataSeeder.seedIfNeeded(in: container.viewContext)
    }

    /// Convenience save that no-ops when there are no pending changes.
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            // Swap this for proper error reporting once we have UI for it.
            assertionFailure("Failed to save Core Data context: \(error)")
        }
    }
}
