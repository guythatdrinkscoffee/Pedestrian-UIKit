//
//  SettingsScreen.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/14/23.
//

import UIKit

class SettingsScreen: UIViewController {
    // MARK: - Properties
    private var feedbackImpactGenerator: UIImpactFeedbackGenerator?
        
    // MARK: - UI
    private lazy var settingsTableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuration
        configureViewController()
        configureNavigationBar()
        
        // Layout
        layoutViews()
    }
}

// MARK: - Configuration
private extension SettingsScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Settings"
    }
    
    private func configureNavigationBar() {
        feedbackImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackImpactGenerator?.prepare()
        
        let rightBarButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction(){ _ in
            self.feedbackImpactGenerator?.impactOccurred()
            
            self.dismiss(animated: true) {
                self.feedbackImpactGenerator = nil
            }
        })
        
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Layout
private extension SettingsScreen {
    private func layoutViews() {
        view.addSubview(settingsTableView)
        
        NSLayoutConstraint.activate([
            settingsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
