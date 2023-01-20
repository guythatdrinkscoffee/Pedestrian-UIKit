//
//  UIImage+Ext.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/9/23.
//

import Foundation
import UIKit

extension UIImage {
    static let cal = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
    static let arrowUp = UIImage(systemName: "arrow.up.forward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
    static let arrowDown = UIImage(systemName: "arrow.down.forward",withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
    static let crown = UIImage(systemName: "crown.fill")
    static let walking = UIImage(systemName: "figure.walk",withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
    static let flag = UIImage(systemName: "flag.filled.and.flag.crossed", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
    static let settings =   UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
    
    
    // settings
    static let general = UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
    static let twitter = UIImage(systemName: "at", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
    static let mail = UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
    static let hand = UIImage(systemName: "hand.raised.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
}
