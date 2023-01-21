//
//  SettingsSelection.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import Foundation

protocol Selection: Hashable {
    var title: String { get }
    var value: Int { get }
}

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

struct SettingsSelection: SettingsOption {
    let title: String
    let highlight: Bool
    let options: [SettingsSection]?
    var selection: any Selection
    let data: [any Selection]
    let key: String
    
    init(title: String, highlight: Bool = true, options: [SettingsSection]? = nil,selection: any Selection, data: [any Selection], key: String){
        self.title = title
        self.highlight = highlight
        self.options = options
        self.selection = selection
        self.data = data
        self.key = key
    }
    
    func withReuseIdentifier() -> String {
        return "SelectionCell"
    }

    mutating func updateSelection(with newSelection: any Selection){
        self.selection = newSelection
    }
}
