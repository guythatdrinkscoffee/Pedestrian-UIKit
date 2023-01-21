//
//  SettingsManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/17/23.
//

import Foundation
import Combine

extension UserDefaults {
    @objc dynamic
    public var dailyStepGoal: Int {
        return Int(self.double(forKey: .dailyStepGoal))
    }
    
    @objc dynamic
    public var distanceUnits: Int {
        return self.integer(forKey: .distanceUnits)
    }
}

final class SettingsManager {
    // MARK: - Public Properties
    public var dailyStepGoalPublisher = CurrentValueSubject<Int?,Never>(nil)
    public var distanceUnitsPublisher = CurrentValueSubject<DistanceUnits?, Never>(nil)
    
    // MARK: - Private Properties
    private var cancellables: Set<AnyCancellable>
    
    // MARK: - Life cycle
    init() {
        self.cancellables = []
        
        shouldSetDefaultSettings()
    }
}

// MARK: - Private Methods
private extension SettingsManager {
    private func shouldSetDefaultSettings() {
        guard !UserDefaults.standard.bool(forKey: .defaultSettingsSet) else {
            print("Default settings are set")
            setCurrentSettings()
            listenToSettings()
            return
        }
        
        setDefaultSettings()
    }
    
    private func setDefaultSettings() {
        let defaultSettings: [String: Any] = [
            .dailyStepGoal : 10_000,
            .distanceUnits : determineDistanceUnits(),
            .analyticsCollectionAllowed: true
        ]
        
        for (k,v) in defaultSettings {
            set(value: v, key: k)
        }
        
        UserDefaults.standard.set(true, forKey: .defaultSettingsSet)
    }
    
    private func determineDistanceUnits() -> Int {
        let usesMetric = Locale.current.usesMetricSystem
        
        if usesMetric {
            return DistanceUnits.kilometers.rawValue
        } else {
            return DistanceUnits.miles.rawValue
        }
    }
    
    private func set<T: Any>(value: T, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func setCurrentSettings() {
        let dailyStepGoal = UserDefaults.standard.dailyStepGoal
        let distanceUnits = DistanceUnits(rawValue: UserDefaults.standard.distanceUnits) ?? .miles
        
        dailyStepGoalPublisher.send(dailyStepGoal)
        distanceUnitsPublisher.send(distanceUnits)
    }
    
    private func listenToSettings() {
        UserDefaults.standard
            .publisher(for: \.dailyStepGoal,options: [.new])
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .compactMap({$0})
            .assign(to: \.dailyStepGoalPublisher.value, on: self)
            .store(in: &cancellables)
        
        UserDefaults.standard
            .publisher(for: \.distanceUnits, options: [.new])
            .map({ return DistanceUnits(rawValue: $0)})
            .assign(to: \.distanceUnitsPublisher.value, on: self)
            .store(in: &cancellables)
    }
}
