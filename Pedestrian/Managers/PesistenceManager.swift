//
//  PesistenceManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/13/23.
//

import Foundation
import CoreMotion
import CoreData

final class PesistenceManager {
    // MARK: - Public Instance
    static let shared = PesistenceManager()
    
    // MARK: - Private Properties
    private var dataStore: PedestrianDataStore
    
    // MARK: - Init
    private init(_ dataStore: PedestrianDataStore = PedestrianDataStore(modelName: "Pedestrian")) {
        self.dataStore = dataStore
    }
    
    // MARK: - Public Methods
    public func save(_ pedometerData: CMPedometerData){
        let entry: PedestrianDay = .findOrInsert(in: dataStore.managedContext, for: pedometerData.startDate, and: pedometerData.endDate)
        
        if entry.objectID.isTemporaryID {
            // The pedometerData object has not yet been saved
            entry.startDate = pedometerData.startDate
            entry.endDate = pedometerData.endDate
            entry.numberOfSteps = pedometerData.numberOfSteps.int16Value
            entry.goalReached = pedometerData.numberOfSteps.intValue >= 4000
        }
    }
    
    public  func saveChanges() {
        self.dataStore.save()
    }
}
