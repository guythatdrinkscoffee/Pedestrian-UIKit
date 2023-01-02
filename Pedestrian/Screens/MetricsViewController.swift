//
//  MetricsViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit


class MetricsViewController: UIViewController {
    // MARK: - Properties
    fileprivate enum DrawerState {
        case compact
        case open
    }
    
    public var minimumHeight: CGFloat = 0.0
    
    public var cornerRadius: CGFloat = 15
    
    private var fullHeight: CGFloat {
        return (self.parent?.view.frame.height ?? 0.0) * 1
    }
    
    private var state: DrawerState = .compact
    
    // MARK: - UI
    private lazy var actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage(
                systemName: "chevron.compact.up",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)), for: .normal)
        button.addTarget(self, action: #selector(handleActionTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config
        configureViewController()
        
        // layout
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func snapTo(height: CGFloat) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            let frame = self.view.frame
            self.view.frame = CGRectMake(0, frame.height - height, frame.width, frame.height)
        }
    }
    
    
}

// MARK: - Config
private extension MetricsViewController {
    private func configureViewController() {
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = cornerRadius
    }
}

// MARK: - Layout
private extension MetricsViewController {
    private func layoutViews(){
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Methods
private extension MetricsViewController {
    @objc
    private func handleActionTap(_ sender: UIButton){
        switch state {
        case .compact:
            self.state = .open
            snapTo(height: fullHeight)
        case .open:
            self.state = .compact
            snapTo(height: minimumHeight)
        }
        
        UIView.animate(withDuration:0.5, animations: { () -> Void in
            if sender.transform == .identity {
                sender.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.999))
            } else {
                sender.transform = .identity
            }
        })
    }
}
