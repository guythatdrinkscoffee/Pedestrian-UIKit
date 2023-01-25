//
//  PesistenceManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/13/23.
//

import Foundation
import CoreMotion
import CoreData

final class PersistenceManager {
    // MARK: - Public Instance
    static let shared = PersistenceManager()
    
    // MARK: - Private Properties
    private var dataStore: PedestrianDataStore
    
    // MARK: - Init
    private init(_ dataStore: PedestrianDataStore = PedestrianDataStore(modelName: "Pedestrian")) {
        self.dataStore = dataStore
    }
    
    // MARK: - Public Methods
    public func save(_ pedometerData: CMPedometerData, dailyStepGoal: Int){
        let entry: PedestrianDay = .findOrInsert(in: dataStore.managedContext, for: pedometerData.startDate, and: pedometerData.endDate)
        
        if entry.objectID.isTemporaryID {
            // The pedometerData object has not yet been saved
            entry.startDate = pedometerData.startDate
            entry.endDate = pedometerData.endDate
            entry.numberOfSteps = pedometerData.numberOfSteps.int32Value
            entry.distanceInMeters = pedometerData.distance?.doubleValue ?? 0.0
            entry.goalReached = pedometerData.numberOfSteps.intValue >= dailyStepGoal
        } else {
            if let start = entry.startDate, let end = entry.endDate {
                if Calendar.current.isDateInYesterday(start) || Calendar.current.isDateInYesterday(end) {
                    entry.endDate = pedometerData.endDate
                    entry.numberOfSteps = pedometerData.numberOfSteps.int32Value
                    entry.distanceInMeters = pedometerData.distance?.doubleValue ?? 0.0
                    entry.goalReached = pedometerData.numberOfSteps.intValue >= dailyStepGoal
                }
            }
        }
    }
    
    public func saveWithCompletion(_ pedometerData: CMPedometerData, completed: Bool){
        let entry: PedestrianDay = .findOrInsert(in: dataStore.managedContext, for: pedometerData.startDate, and: pedometerData.endDate)

        if entry.objectID.isTemporaryID {
            entry.goalReached = completed
            entry.startDate = pedometerData.startDate
            entry.endDate = pedometerData.endDate
            
            PersistenceManager.shared.saveChanges()
        }
    }
    
    public func findEntry(with pedometerData: CMPedometerData) -> PedestrianDay? {
        let possibleEntry: PedestrianDay = .findOrInsert(in: dataStore.managedContext, for: pedometerData.startDate, and: pedometerData.endDate)
        
        if possibleEntry.objectID.isTemporaryID {
            return nil
        } else {
            return possibleEntry
        }
    }

    public func getAll() -> [PedestrianDay] {
        let allEntries: [PedestrianDay] = PedestrianDay.all(in: dataStore.managedContext)
        return allEntries
    }
    
    public  func saveChanges() {
        self.dataStore.save()
    }
}
