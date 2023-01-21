//
//  SettingsStepper.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import Foundation

struct SettingsStepper: SettingsOption {
    let icon: SettingsIcon?
    let title: String
    let options: [SettingsSection]?
    let highlight: Bool
    let minimum: Double
    let maximum: Double
    let stepBy: Double
    let key: String
    
    init(
        icon: SettingsIcon? = nil,
        title: String,
        options: [SettingsSection]? = nil,
        highlight: Bool = false,
        minimum: Double,
        maximum: Double,
        stepBy: Double = 100,
        key: String) {
            self.icon = icon
            self.title = title
            self.options = options
            self.highlight = highlight
            self.minimum = minimum
            self.maximum = maximum
            self.stepBy = stepBy
            self.key = key
    }
    
    func withReuseIdentifier() -> String {
        return "StepperCell"
    }
    
    func withRowHeight() -> CGFloat {
        return 80
    }
}
