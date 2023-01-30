//
//  UIImage+Ext.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/9/23.
//O

import Foundation
import UIKit

extension UIImage {
    static let arrowUp = UIImage(systemName: "arrow.up.forward", withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .headline), scale: .medium))
    static let arrowDown = UIImage(systemName: "arrow.down.forward",withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .headline), scale: .medium))
    static let walking = UIImage(systemName: "figure.walk",withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .headline), scale: .medium))
    static let settings =   UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
  
    // settings
    static let general = UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
    static let twitter = UIImage(systemName: "at", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
    static let export = UIImage(systemName: "square.and.arrow.up.on.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium))
}
