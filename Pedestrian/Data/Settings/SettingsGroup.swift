//
//  SettingsGroup.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/19/23.
//

import Foundation

struct SettingsGroup: SettingsOption {
    let icon: SettingsIcon
    let title: String
    let highlight: Bool
    let options: [SettingsSection]?
    
    init(icon: SettingsIcon, title: String, highlight: Bool = true, options: [SettingsSection]?) {
        self.icon = icon
        self.title = title
        self.highlight = highlight
        self.options = options
    }
    
    func withReuseIdentifier() -> String {
       return "GroupCell"
    }
}
