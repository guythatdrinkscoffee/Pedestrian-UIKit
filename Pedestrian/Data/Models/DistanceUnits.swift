//
//  DistanceUnits.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/26/23.
//

import Foundation


enum DistanceUnits: Int, CaseIterable, Selection, Equatable{
    case miles = 0
    case kilometers = 1
    
    var title: String {
        switch self {
        case .miles:
            return "Miles"
        case .kilometers:
            return "Kilometers"
        }
    }
    
    var value: Int {
        return rawValue
    }
}
