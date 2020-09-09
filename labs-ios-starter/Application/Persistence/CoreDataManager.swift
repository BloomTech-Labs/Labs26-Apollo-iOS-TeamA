// Copyright © 2020 Shawn James. All rights reserved.
// CoreDataManager.swift

import CoreData

/// Used to interact with persisted managed objects and the application's xcdatamodeld
class CoreDataManager {
    static let shared = CoreDataManager() // singleton
    
    // persistent container
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "labs-ios-starter")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return persistentContainer
    }()
    
    // view context
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Methods
    
    /// Saves to the main context with error handling.
    func save() {
        do {
            try mainContext.save()
        } catch {
            print("Error in CoreDataManager's save method : \(error)")
        }
    }
    
    /// Deletes from the main context with error handling.
    func delete(_ object: NSManagedObject) {
        do {
            mainContext.delete(object)
            try mainContext.save()
        } catch {
            print("Error in CoreDataManager's delete method : \(error)")
        }
    }
    
}

