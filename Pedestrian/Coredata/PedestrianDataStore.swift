//
//  PedestrianDataStore.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/13/23.
//

import Foundation
import CoreData

final class PedestrianDataStore {
    private var modelName: String
    
    // MARK: - Life cycle
    init(modelName: String) {
        self.modelName = modelName
    }
    
    public var managedContext: NSManagedObjectContext {
        return persistentStore.viewContext
    }
    
    private lazy var persistentStore : NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Failed to load the persistent store")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    public func save() {
        guard managedContext.hasChanges else {
            return
        }
        
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            try managedContext.save()
            let endTime = CFAbsoluteTimeGetCurrent()
            print("Context Save took: \(endTime - startTime) seconds")
        } catch {
            if managedContext.hasChanges {
                managedContext.rollback()
            }
            
            print(error.localizedDescription)
        }
    }
}
