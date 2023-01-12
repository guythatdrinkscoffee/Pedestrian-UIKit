//
//  PedometerManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import Foundation
import CoreMotion
import Combine

final class PedometerManager {
    // MARK: - Properties
    
    // pedometerData holds the data for the currentDay
    public  var currentPedometerData = PassthroughSubject<CMPedometerData,Never>()
    
    private var pedometer: CMPedometer
    
    private var calendar: Calendar
    
    // MARK: - Life cycle
    init(calendar: Calendar = .current) {
        self.pedometer = CMPedometer()
        self.calendar = calendar
    }
    
    // MARK: - Private Method
    
    private func fetchFor(_ date: Date) {
        
        let startOfDay = calendar.startOfDay(for: date)
        
        self.pedometer.startUpdates(from: startOfDay) { pedometerData, error in
            guard error == nil, let pedData = pedometerData else {
                print(error!.localizedDescription)
                return
            }
            
            self.currentPedometerData.send(pedData)
        }
    }
    
    private func fetchDataInRange(from d1: Date, to d2: Date) -> AnyPublisher<CMPedometerData, Error> {
        return Future { promise in
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
    
    private func mergeData(_ dates: [Date]) -> AnyPublisher<CMPedometerData, Error> {
        let initialDate = dates[0]
        let initialPublisher = fetchDataInRange(from: initialDate.startOfDay, to: initialDate.startOfDay.endOfDay)
        let remainingDates = Array(dates.dropFirst())
        
        return remainingDates.reduce(initialPublisher) { combined, date in
            let start = date.startOfDay
            let end = start.endOfDay
            
            return combined
                .merge(with: fetchDataInRange(from: start, to: end))
                .eraseToAnyPublisher()
        }
    }
    
    private func getLastSevenDays(from date: Date = .now) -> [Date] {
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else { return [] }
        var dates = [Date]()
        
        for i in 0..<7 {
            if let previousDay = calendar.date(byAdding: .day, value: -i, to: previousDate) {
                dates.append(previousDay)
            }
        }
        
        return dates
    }
    
    private func getCurrentWeek(from date: Date = .now) -> [Date] {
        let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: date)
        var dates = [Date]()
        
        guard let startOfWeek = weekInterval?.start else {
            return []
        }
        
        for i in 0..<7 {
            if let nextDay = calendar.date(byAdding: .day,value: i, to: startOfWeek){
                dates.append(nextDay)
            }
        }
        
        return dates
    }
    
    // MARK: - Public Methods
    public func determineAuthorizationStatus() -> CMAuthorizationStatus {
        return CMPedometer.authorizationStatus()
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
    
    public func startLiveUpdates() {
        fetchFor(.now)
    }
    
    public func stopLiveUpdates() {
        pedometer.stopUpdates()
    }
    
    public func getStepsForLastSevenDays() -> AnyPublisher<[CMPedometerData],Error> {
        let lastSevenDays = getLastSevenDays()
        
        return mergeData(lastSevenDays)
            .collect()
            .map({$0.reversed()})
            .eraseToAnyPublisher()
    }
    
    public func getStepsForCurrentWeek() -> AnyPublisher<[CMPedometerData], Error> {
        let currentWeek = getCurrentWeek()
        
        return mergeData(currentWeek)
            .collect()
            .eraseToAnyPublisher()
    }
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: self)!
    }
}
