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
}

final class SettingsManager {
    // MARK: - Public Properties
    public var dailyStepGoalPublisher = CurrentValueSubject<Int?,Never>(nil)
    
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
            .dailyStepGoal : 10_000
        ]
        
        for (k,v) in defaultSettings {
            set(value: v, key: k)
        }
        
        UserDefaults.standard.set(true, forKey: .defaultSettingsSet)
    }
    
    private func set<T: Any>(value: T, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func setCurrentSettings() {
        let dailyStepGoal = UserDefaults.standard.dailyStepGoal
        dailyStepGoalPublisher.send(dailyStepGoal)
    }
    
    private func listenToSettings() {
        UserDefaults.standard
            .publisher(for: \.dailyStepGoal,options: [.new])
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .compactMap({$0})
            .print()
            .assign(to: \.dailyStepGoalPublisher.value, on: self)
            .store(in: &cancellables)
    }
}
