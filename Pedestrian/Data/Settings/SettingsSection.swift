//
//  SettingsSection.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/19/23.
//

import Foundation

public struct SettingsSection {
    let headerTitle: String?
    var settings: [SettingsOption]
    let footerTitle: String?
    let detailTitle: String?
    
    init(title: String? = nil, settings: [SettingsOption], footerTitle: String? = nil, detailTitle: String? = nil) {
        self.headerTitle = title
        self.settings = settings
        self.footerTitle = footerTitle
        self.detailTitle = detailTitle
    }
    
    mutating func updateSetting(at index:Int, with setting: SettingsOption){
        settings[index] = setting
    }
}

