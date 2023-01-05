//
//  OpenSettingsViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/4/23.
//

import UIKit

class OpenSettingsViewController: UIViewController {
    
    // MARK: - UI
    private lazy var settingsLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.text = "Enable Motion & Fitness"
        return label
    }()
    
    private lazy var bodyLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "Pedestrian needs permission to access your motion & fitness data in order to show your step count. "
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var settingsButton : UIButton = {
        var config = UIButton.Configuration.bordered()
        var string = NSAttributedString(string: "Open Settings", attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)])
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white
        config.buttonSize = .large
        config.attributedTitle = AttributedString(string)
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.image = UIImage(systemName: "gearshape")
        
        let button = UIButton(configuration: config, primaryAction: UIAction(){ _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        })
        
        return button
    }()
    
    private lazy var rootStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [settingsLabel, bodyLabel, settingsButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // layout
        layoutViews()
    }
    
    private func layoutViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rootStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rootStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        ])
    }

}
