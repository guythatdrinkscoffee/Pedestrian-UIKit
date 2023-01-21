//
//  SettingsSection.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/19/23.
//

import Foundation

public struct SettingsSection {
    let title: String
    var settings: [SettingsOption]
    
    init(title: String, settings: [SettingsOption]) {
        self.title = title
        self.settings = settings
    }
    
    mutating func updateSetting(at index:Int, with setting: SettingsOption){
        settings[index] = setting
    }
}

