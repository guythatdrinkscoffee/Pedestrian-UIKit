//
//  LoadingStatusViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/4/23.
//

import UIKit

class LoadingStatusScreen: UIViewController {
    // MARK: - UI
    private lazy var activityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //layout
        layoutViews()
        
        activityIndicator.startAnimating()
    }
    
    
    private func layoutViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


}
