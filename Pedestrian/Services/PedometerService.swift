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
            
            self.pedometerData.send(pedData)
        }
    }
    
    private func fetchDataInRange(from d1: Date, to d2: Date) -> AnyPublisher<CMPedometerData, Error> {
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
    
    private func mergeData(_ dates: [Date]) -> AnyPublisher<CMPedometerData, Error> {
        let initialPublisher = fetchDataInRange(from: calendar.startOfDay(for: dates[0]), to: calendar.endOfDay(dates[0]))
        let remainingDates = Array(dates.dropFirst())
        
        return remainingDates.reduce(initialPublisher) { combined, date in
            let start = calendar.startOfDay(for: date)
            let end = calendar.endOfDay(date)
            
            return combined
                .merge(with: fetchDataInRange(from: start, to: end))
                .eraseToAnyPublisher()
        }
    }
    
    private func getCurrentWeek(date: Date = .now) -> [Date] {
        let cal = Calendar.current
        let currentDate = date
        var dates = [Date]()
        
        let weekInterval = cal.dateInterval(of: .weekOfMonth, for: currentDate)
        
        guard let startOfWeek = weekInterval?.start else {
            return []
        }
        
        for i in 0..<7 {
            if let nextDay = cal.date(byAdding: .day,value: i, to: startOfWeek){
                dates.append(nextDay)
            }
        }
        
        return dates
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
    
    public func startLiveUpdates(){
        fetchFor(.now)
    }
    
    public func getStepsForCurrentWeek() -> AnyPublisher<[CMPedometerData], Error> {
        let week = getCurrentWeek()
        
        return mergeData(week)
            .collect()
            .eraseToAnyPublisher()
    }
}

extension Calendar {
    func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: date)!
    }
}
