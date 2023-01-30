//
//  SettingsIcon.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/19/23.
//

import UIKit

struct SettingsIcon {
    let image: UIImage?
    let color: UIColor
    
    func makeView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.layer.cornerCurve = .continuous
        containerView.backgroundColor = color
        
        let iconImageView = UIImageView(image: image)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 30),
            containerView.widthAnchor.constraint(equalToConstant: 30),
            
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
        
        return containerView
    }
}

extension SettingsIcon {
    static let general = SettingsIcon(image: .general, color: .systemGray)
    static let twitter = SettingsIcon(image: .twitter, color: .systemBlue)
    static let privacy = SettingsIcon(image: .hand, color: .systemGray)
    static let export = SettingsIcon(image: .export, color: .systemPink)
}
