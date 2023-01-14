//
//  UICollectionViewLayout+Ext.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/11/23.
//

import Foundation
import UIKit

extension UICollectionViewLayout {
    static func twoColumnLayout(for view: UIView) -> UICollectionViewFlowLayout {
        let totalWidth = view.bounds.width
        let padding: CGFloat = 10
        let itemSpacing: CGFloat = 10
        
        let availableWidth = totalWidth - (padding * 2) - (itemSpacing)
        
        let itemWidth = availableWidth / 2
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: padding / 2, left: padding, bottom: padding / 2, right: padding)
        layout.itemSize = CGSize(width: itemWidth, height: 80)
        
        return layout
    }
}
