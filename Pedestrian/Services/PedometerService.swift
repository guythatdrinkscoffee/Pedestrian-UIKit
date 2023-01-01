//
//  PedometerService.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import Foundation
import CoreMotion
import Combine
 
final class PedometerService {
    // MARK: - Properties
    
    // pedometerData holds the data for the currentDay
    public  var pedometerData = PassthroughSubject<CMPedometerData,Never>()
    
    
    private var pedometer: CMPedometer
    
    // MARK: - Life cycle
    init() {
        pedometer = CMPedometer()
    }
    
    // MARK: - Private Method
    
    private func fetchFor(_ date: Date) {
        pedometer.startUpdates(from: date) { pedometerData, error in
            guard error == nil, let pedData = pedometerData else {
                print(error!.localizedDescription)
                return
            }
            
            self.pedometerData.send(pedData)
        }
    }
    
    // MARK: - Public Methods
    public func determineAuthorizationStatus() -> AnyPublisher<CMAuthorizationStatus, Never> {
        let status = CMPedometer.authorizationStatus()
        return Just(status).eraseToAnyPublisher()
    }
    
    public func makeAuthorizationRequest(completion: @escaping () -> Void) {
        pedometer.queryPedometerData(from: .now, to: .now) { pedometerData, error in
            guard error == nil, let _ = pedometerData else {
                completion()
                return
            }
            
            completion()
        }
    }
    
    public func fetchDataInRange(from d1: Date, to d2: Date) -> AnyPublisher<CMPedometerData, Error> {
        Future { promise in
            self.pedometer.queryPedometerData(from: d1, to: d2) { pedometerData, error in
                guard error == nil, let pedData = pedometerData else {
                    promise(.failure(error!))
                    return
                }
                
                promise(.success(pedData))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func startForCurrentDay(_ date: Date) {
        let calender = Calendar.current
        let startOfDay = calender.startOfDay(for: date)
        fetchFor(startOfDay)
    }
}

