//
//  SettingsSection.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/19/23.
//

import Foundation

public struct SettingsSection {
    let title: String
    let settings: [SettingsOption]
    
    init(title: String, settings: [SettingsOption]) {
        self.title = title
        self.settings = settings
    }
}

