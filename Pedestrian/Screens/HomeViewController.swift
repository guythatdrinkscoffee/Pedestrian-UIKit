//
//  HomeViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 12/31/22.
//

import UIKit
import Combine
import CoreMotion

protocol MetricsDelegate: AnyObject {
    func provideWeeklyData(_ viewController: UIViewController)
}


class HomeViewController: UIViewController {
    // MARK: - Properties
    private var pedometerService = PedometerService()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var stepDataCancellable: AnyCancellable?
    
    private var weeklydataCancellable: AnyCancellable?
    
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
    
    private var minOpeningHeight: CGFloat {
        let height = view.frame.height
        let safeAreaTop = view.safeAreaInsets.top
        let padding = 16.0 * 2
        return height - (stepProgressView.frame.height + infoRow.frame.height + padding + safeAreaTop)
    }
    
    private var weeklyStepData: [CMPedometerData] = [] {
        didSet {
            metricsViewController.updateMetrics(weeklyStepData)
        }
    }
    
    private var authorizationStatus: CMAuthorizationStatus = .notDetermined
    
    // MARK: - UI
    private lazy var metricsViewController : MetricsViewController = {
        let controller = MetricsViewController()
        controller.minimumHeight = minOpeningHeight
        controller.delegate = self
        return controller
    }()
    
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
        
        // config
        configureMetricsViewController()
        
        
        checkAuthorizationStatus()
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
    
    private func configureMetricsViewController() {
        add(metricsViewController, frame: CGRectMake(0, view.frame.maxY - minOpeningHeight, view.frame.width, view.frame.height))
    }
}

// MARK: - Layout
private extension HomeViewController {
    private func layoutViews() {
        view.addSubview(stepProgressView)
        view.addSubview(infoRow)
        
        infoRow.addSections([distanceTraveledSection, stairsClimbedSection])
        
        NSLayoutConstraint.activate([
            stepProgressView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.5),
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
        
        stepDataCancellable = pedometerService
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
        weeklydataCancellable = pedometerService
            .getStepsForCurrentWeek()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { weeklyStepData in
                self.weeklyStepData = weeklyStepData
            })
    }
   
    private func updateForLastSevenDays() {
        weeklydataCancellable = pedometerService
            .getStepsForLastSevenDays()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { weeklyStepData in
                self.weeklyStepData = weeklyStepData
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
        self.authorizationStatus = status
        
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
        @unknown default:
            fatalError("failed to determined authorization status")
        }
    }
}

// MARK: - Metrics Delegate
extension HomeViewController: MetricsDelegate {
    func provideWeeklyData(_ viewController: UIViewController) {
        guard authorizationStatus == .authorized else { return }
        updateForLastSevenDays()
    }
}

extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
         addChild(child)

         if let frame = frame {
             child.view.frame = frame
         }

         view.addSubview(child.view)
         child.didMove(toParent: self)
     }

     func remove() {
         willMove(toParent: nil)
         view.removeFromSuperview()
         removeFromParent()
     }
}

