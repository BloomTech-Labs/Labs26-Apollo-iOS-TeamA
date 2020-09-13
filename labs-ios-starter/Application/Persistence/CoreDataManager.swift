// Copyright © 2020 Shawn James. All rights reserved.
// CoreDataManager.swift

import CoreData

/// Used to interact with persisted managed objects and the application's xcdatamodeld
class CoreDataManager {
    
    // MARK: - Properties
    
    /// The singleton used to access the CoreData Stack
    static let shared = CoreDataManager()
    
    /// The container that encapsulates the CoreData Manager/Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "labs-ios-starter")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return persistentContainer
    }()
    
    /// The main object space for managed objects. Uses the main thread.
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Methods
    
    /// Performs a save on the passed-in context.
    /// ```
    /// // Create new background context
    /// CoreDataManager.shared.persistentContainer.newBackgroundContext()
    /// ```
    /// - Warning: Large processes my hang the UI on the mainContext.
    /// - parameter context: the selected object space for managed objects. Defaults to mainContext.
    /// - parameter async: whether or not the action should run async using a perform block
    func saveContext(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext, async: Bool = false) throws {
        var error: Error?
        
        switch async {
            case true:
                context.perform {
                    do {
                        try context.save()
                    } catch let saveError {
                        error = saveError
                    }
            }
            case false:
                context.performAndWait {
                    do {
                        try context.save()
                    } catch let saveError {
                        error = saveError
                    }
            }
        }
        
        if let error = error { throw error }
    }
    
    /// Performs a deletion of a passed-in object on the mainContext
    func deleteObject(_ object: NSManagedObject) {
        let mainContext = CoreDataManager.shared.mainContext
        mainContext.performAndWait {
            do {
                mainContext.delete(object)
                try mainContext.save()
            } catch {
                print("Error in CoreDataManager's delete method : \(error)")
            }
        }
    }
    
}
