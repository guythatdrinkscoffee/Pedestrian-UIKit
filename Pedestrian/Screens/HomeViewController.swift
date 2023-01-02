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
    
    private var weeklydata: AnyCancellable?
    
    private lazy var measurementFormatter : MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        
        formatter.numberFormatter = numberFormatter
        
        return formatter
    }()
    
    private var maxSteps = 10000
    
    // MARK: - UI
    private let stepProgressView = StepProgressView(frame: .zero)
    
    private let stairsClimbedSection = InfoSection(
        icon: UIImage(
            systemName: "arrow.up.right",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
        body: "\(0)",
        detail: "Flights Climbed")
    
    private let distanceTraveledSection =  InfoSection(
        icon: UIImage(
            systemName: "figure.walk",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
        body: "\(0)",
        detail: "Distance Traveled")
    
    private lazy var infoRow : InfoRow = {
        let view = InfoRow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        stepProgressView.updateMax(maxSteps)
    }
    
}

// MARK: - Layout
private extension HomeViewController {
    private func layoutViews() {
        view.addSubview(stepProgressView)
        view.addSubview(infoRow)
        
        infoRow.addSections([stairsClimbedSection, distanceTraveledSection])
        
        NSLayoutConstraint.activate([
            stepProgressView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            stepProgressView.widthAnchor.constraint(equalTo: view.widthAnchor),
            stepProgressView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            stepProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoRow.topAnchor.constraint(equalToSystemSpacingBelow: stepProgressView.bottomAnchor, multiplier: 1),
            infoRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
    
    private func updateWithTimer() {
        var current = 200
        Timer
            .publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                current += 300
                self.updateStepProgress(current as NSNumber)
            }
            .store(in: &cancellables)
    }
    
    private func startUpdatingLiveSteps() {
        pedometerService.startLiveUpdates()
        
        stepData = pedometerService
            .pedometerData
            .sink(receiveValue: { pedometerData in
                DispatchQueue.main.async {
                    self.updateStepProgress(pedometerData.numberOfSteps)
                    self.updateFloorsClimbed(pedometerData.floorsAscended)
                    self.updateDistanceTraveled(pedometerData.distance)
                }
            })
    }
    
    private func updateForCurrentWeek() {
        weeklydata = pedometerService
            .getStepsForCurrentWeek()
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { weeklyStepData in
                print(weeklyStepData)
            })
    }
   
    
    private func updateStepProgress(_ value: NSNumber) {
        DispatchQueue.main.async {
            self.stepProgressView.updateProgress(value.intValue)
        }
    }
    
    private func updateFloorsClimbed(_ value: NSNumber?) {
        stairsClimbedSection.updateBodyLabel("\(value ?? 0.0)")
    }
    
    private func updateDistanceTraveled(_ value: NSNumber?) {
        guard let distanceInMeters = value else { return }
        
        let distance = Measurement<UnitLength>(value: distanceInMeters.doubleValue, unit: .meters).converted(to: .kilometers)
        let formattedDistance = measurementFormatter.string(from: distance)
        
        distanceTraveledSection.updateBodyLabel(formattedDistance)
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
            startUpdatingLiveSteps()
            updateForCurrentWeek()
        @unknown default:
            fatalError("failed to determined authorization status")
        }
    }
}

