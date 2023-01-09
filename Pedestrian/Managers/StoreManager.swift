//
//  StoreManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/9/23.
//

import Foundation
import CoreData

final class StoreManager {
    // MARK: - Properties
    private var modelName: String
    
    // MARK: - Life cycle
    init(_ model: String) {
        self.modelName = model
    }
    
    public var managedContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    private lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
    
    public func save() {
        guard managedContext.hasChanges else {
            return
        }
        
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
            print(error.localizedDescription)
        }
    }
}
