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
    
   // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config
        configureViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthorizationStatus()
    }
}

// MARK: - Config
private extension HomeViewController {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
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
