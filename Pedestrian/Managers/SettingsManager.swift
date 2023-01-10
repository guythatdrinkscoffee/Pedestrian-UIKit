//
//  SettingsManager.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/6/23.
//

import Foundation
import Combine
import SwiftUI


extension UserDefaults {
    @objc dynamic var dailyStepGoal: Int {
        get {
            return self.integer(forKey: .dailyStepGoal)
        }
    }
    
    @objc dynamic var preferMetricUnits: Bool {
        get {
            return self.bool(forKey: .preferMetricUnits)
        }
    }
}

final class SettingsManager: ObservableObject{
    // MARK: - Public Publisher
    public var dailyStepGoal = CurrentValueSubject<Int, Never>(5000)
    public var preferMetricUnits = CurrentValueSubject<Bool,Never>(false)
    
    // MARK: - Private Properties
    private var defaults: UserDefaults
    private var cancellables: Set<AnyCancellable>
    
    // MARK: - Life cycle
    init(_ defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.cancellables = Set<AnyCancellable>()
        shouldSetDefaultSettings()
        listenToSettings()
    }

}

// MARK: - Configuration
private extension SettingsManager {
    private func shouldSetDefaultSettings() {
        guard !defaults.bool(forKey: .defaultSettingsSet) else {
            return
        }

        setDefaultSettings()
    }

    private func setDefaultSettings() {
        let defaultSettings: [String : Any] = [
            .dailyStepGoal : 5000,
            .preferMetricUnits: false,
        ]

        for (k,v) in defaultSettings {
            setSetting(v, for: k)
        }

        defaults.set(true, forKey: .defaultSettingsSet)
    }

    private func listenToSettings() {
        defaults.publisher(for: \.dailyStepGoal)
            .assign(to: \.value, on: dailyStepGoal)
            .store(in: &cancellables)
        
        defaults.publisher(for: \.preferMetricUnits)
            .assign(to: \.value, on: preferMetricUnits)
            .store(in: &cancellables)
    }
}

// MARK: - Private Methods
private extension SettingsManager {
    private func setSetting<T: Any> (_ value: T, for key: String) {
        defaults.set(value, forKey: key)
    }
}
