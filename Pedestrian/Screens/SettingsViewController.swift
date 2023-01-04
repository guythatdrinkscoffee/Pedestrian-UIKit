//
//  SettingsViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/3/23.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config
        configureViewController()
        configureNavigationBar()
    }
    
}

// MARK: - Configuration
private extension SettingsViewController {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Settings"
    }
    
    private func configureNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneTap(_:)))
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Private Methods
private extension SettingsViewController {
    @objc
    private func handleDoneTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
