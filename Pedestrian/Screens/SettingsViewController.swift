//
//  SettingsViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/3/23.
//

import UIKit

class SettingsViewController: UIViewController {
    // MARK: - UI
    private var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    // MARK: - Life cycle
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
        feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator?.prepare()
        feedbackGenerator?.impactOccurred()
    
        self.dismiss(animated: true) {
            self.feedbackGenerator = nil
        }
    }
}