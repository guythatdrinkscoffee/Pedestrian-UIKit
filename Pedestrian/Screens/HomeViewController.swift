//
//  HomeViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 12/31/22.
//

import UIKit
import Combine
import CoreMotion

class HomeViewController: UIViewController {
    // MARK: - Properties
    private var pedometerService = PedometerService()
    private var cancellables = Set<AnyCancellable>()
    private var stepData: AnyCancellable?
    
    // MARK: - UI
    private let stepProgressView = StepProgressView(frame: .zero)
  
   // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config
        configureViewController()
        configureProgressView()
        
        // layout
        layoutViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
        checkAuthorizationStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
    }
}

// MARK: - Config
private extension HomeViewController {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureProgressView() {
        stepProgressView.translatesAutoresizingMaskIntoConstraints = false
        stepProgressView.updateMax(10000)
    }
}

// MARK: - Layout
private extension HomeViewController {
    private func layoutViews() {
        view.addSubview(stepProgressView)
        
        NSLayoutConstraint.activate([
            stepProgressView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            stepProgressView.widthAnchor.constraint(equalTo: view.widthAnchor),
            stepProgressView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
        ])
    }
}

// MARK: - Methods
private extension HomeViewController {
    private func checkAuthorizationStatus() {
        pedometerService
            .determineAuthorizationStatus()
            .sink { status in
                self.handleStatus(status)
            }
            .store(in: &cancellables)
    }
    
    private func startUpdatingSteps() {
        pedometerService
            .startForCurrentDay(.now)
        
        stepData = pedometerService
            .pedometerData
            .sink { pedometerData in
                print(pedometerData.numberOfSteps)
                self.updateStepProgress(pedometerData.numberOfSteps)
            }
    }
    
    private func updateStepProgress(_ value: NSNumber) {
        DispatchQueue.main.async {
            self.stepProgressView.updateProgress(value.intValue)
        }
    }
    
    private func handleStatus(_ status: CMAuthorizationStatus) {
        switch status {
        case .notDetermined:
            pedometerService.makeAuthorizationRequest {
                self.checkAuthorizationStatus()
            }
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorized:
            startUpdatingSteps()
        @unknown default:
            fatalError("failed to determined authorization status")
        }
    }
}
