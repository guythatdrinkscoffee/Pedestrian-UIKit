//
//  SettingsAction.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import Foundation

struct SettingsAction: SettingsOption {
    let icon: SettingsIcon?
    let title: String
    let highlight: Bool
    let options: [SettingsSection]?
    let action: (()->Void)
    
    init(icon: SettingsIcon? = nil , title: String,highlight: Bool = true ,options: [SettingsSection]? = nil, _ action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.highlight = highlight
        self.options = options
        self.action = action
    }
    
    func withReuseIdentifier() -> String {
        return "ActionCell"
    }
}
