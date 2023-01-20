//
//  PedestrianDay+CoreDataProperties.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/13/23.
//
//

import Foundation
import CoreData


extension PedestrianDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PedestrianDay> {
        return NSFetchRequest<PedestrianDay>(entityName: "PedestrianDay")
    }

    @NSManaged public var distanceInMeters: Double
    @NSManaged public var endDate: Date?
    @NSManaged public var goalReached: Bool
    @NSManaged public var identifier: UUID?
    @NSManaged public var numberOfSteps: Int32
    @NSManaged public var startDate: Date?

}

extension PedestrianDay : Identifiable {

}

extension PedestrianDay {
    static func findOrInsert(in context: NSManagedObjectContext, for startDate: Date, and endDate: Date) -> PedestrianDay {
        let dateRangePredicate = NSPredicate(format: "startDate >= %@ && endDate <= %@", startDate as CVarArg, endDate as CVarArg)
        let fetchRequest: NSFetchRequest<PedestrianDay>  = PedestrianDay.fetchRequest()
        fetchRequest.predicate = dateRangePredicate
        
        if let entry = try? context.fetch(fetchRequest).first {
            return entry
        } else {
            let newEntry = PedestrianDay(context: context)
            newEntry.identifier = UUID()
            return newEntry
        }
    }
    
    static func all(in context: NSManagedObjectContext) -> [PedestrianDay] {
        let fetchRequest: NSFetchRequest<PedestrianDay> = PedestrianDay.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        if let results = try? context.fetch(fetchRequest) {
            return results
        } else {
            return []
        }
    }
}
