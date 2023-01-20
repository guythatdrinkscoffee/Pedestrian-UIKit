//
//  SettingsCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

public protocol SettingsCell: UITableViewCell {
    func set(setting: SettingsOption)
}
