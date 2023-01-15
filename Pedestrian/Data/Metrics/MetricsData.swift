//
//  MetricsData.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/14/23.
//

import UIKit

struct MetricsData {
    let icon: UIImage?
    let description: String?
    let value: Any?
    let color: UIColor?
    
    init(icon: UIImage? = nil, description: String?, value: Any?, color: UIColor? = nil) {
        self.icon = icon
        self.description = description
        self.value = value
        self.color = color
    }
}
