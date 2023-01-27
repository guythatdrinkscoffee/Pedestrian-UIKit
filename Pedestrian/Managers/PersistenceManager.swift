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
        }
    }

    public func getAll() -> [PedestrianDay] {
        let allEntries: [PedestrianDay] = PedestrianDay.all(in: dataStore.managedContext)
        return allEntries
    }
    
    public func getCurrentStreak() -> (Int, Int){
        let allEntries = self.getAll()
        
        var start = allEntries.first?.startDate
        var end = allEntries.first?.startDate
        var count = 0
        var maxCount = 0
        
        for entry in allEntries {
            if entry.goalReached {
                end = entry.startDate
                count += 1
               
            } else {
                start = entry.startDate
                end = entry.startDate
                count = 0
            }
            
            maxCount = max(maxCount, count)
        }
        
        print("Current Streak 🔥: \(count)")
        print("Max Streak 🔥: \(maxCount)")
        print("Streak Start 🗓: \(start ?? .now)")
        print("Streak End 🗓: \(end ?? .now)")
        
        return (count, maxCount)
    }
    
    public func getFirstEntryDate() -> Date {
        return PedestrianDay.all(in: dataStore.managedContext).first?.startDate ?? .now
    }
    
    public  func saveChanges() {
        self.dataStore.save()
    }
}
