//
//  SettingOption.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/19/23.
//

import Foundation

public protocol SettingsOption: Any {
    var title: String { get }
    var options: [SettingsSection]? { get }
    var highlight: Bool { get }
    
    func withReuseIdentifier() -> String
    func withRowHeight() -> CGFloat
}

extension SettingsOption {
    func withRowHeight() -> CGFloat {
        return 50
    }
}
