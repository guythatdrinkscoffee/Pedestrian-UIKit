//
//  SettingsSwitch.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import Foundation

struct SettingsSwitch: SettingsOption {
    let title: String
    let highlight: Bool
    let options: [SettingsSection]?
    let isOn: Bool
    let key: String
    
    init(title: String, highlight: Bool = false, options: [SettingsSection]? = nil, isOn: Bool, key: String){
        self.title = title
        self.highlight = highlight
        self.options = options
        self.isOn = isOn
        self.key = key
    }
    
    func withReuseIdentifier() -> String {
        return "SwitchCell"
    }
}
