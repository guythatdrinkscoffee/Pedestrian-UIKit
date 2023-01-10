//
//  Entry+CoreDataProperties.swift
//  
//
//  Created by J Manuel Zaragoza on 1/9/23.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var didComplete: Bool
    @NSManaged public var date: Date?
    
}

// MARK: - Static Methods
extension Entry {
    static func findOrInsert(_ date: Date, in context: NSManagedObjectContext) -> Entry {
        let request : NSFetchRequest<Entry> = Entry.fetchRequest()
        
        request.predicate = NSPredicate(format: "date >= %@ && date <= %@", date.startOfDay as CVarArg, date.startOfDay.endOfDay as CVarArg)
        
        if let existingEntry = try? context.fetch(request).first {
            return existingEntry
        } else {
            let newEntry = Entry(context: context)
            return newEntry
        }
    }
    
    static func getCompleted(in context: NSManagedObjectContext) -> [Entry] {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        request.predicate = NSPredicate(format: "didComplete == %@", NSNumber(value: true))
        
        if let results = try? context.fetch(request) {
            return results
        } else {
            return []
        }
    }
}
