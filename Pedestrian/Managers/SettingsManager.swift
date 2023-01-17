//
//  SettingsManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/17/23.
//

import Foundation

final class SettingsManager {
    // MARK: - Life cycle
    init() {
        shouldSetDefaultSettings()
    }
}

// MARK: - Private Methods
private extension SettingsManager {
    private func shouldSetDefaultSettings() {
        guard !UserDefaults.standard.bool(forKey: .defaultSettingsSet) else {
            print("Default settings are set")
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
}
