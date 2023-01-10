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


class HomeScreen: UIViewController {
    // MARK: - Properties
    private var pedometerManager: PedometerManager?
    
    private var settingsManager: SettingsManager?
    
    private var storeManager: StoreManager?
    
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
    
    
    private var minOpeningHeight: CGFloat {
        let height = view.frame.height
        let safeAreaTop = view.safeAreaInsets.top
        let padding = 16.0 * 2.5
        return height - (stepProgressView.frame.height + infoRow.frame.height + padding + safeAreaTop)
    }
    
    private var weeklyStepData: [CMPedometerData] = [] {
        didSet {
            metricsViewController.setData(data: weeklyStepData)
        }
    }
    
    private var currentStepData: CMPedometerData? {
        didSet {
            update(currentStepData)
        }
    }
    
    private var unitDistance: UnitLength = .kilometers {
        didSet {
            update(currentStepData)
            metricsViewController.unitDistance = unitDistance
        }
    }
    
    private var dailyStepGoal: Int  = 5000 {
        didSet {
            stepProgressView.updateMax(dailyStepGoal)
            metricsViewController.limit = Double(dailyStepGoal)
        }
    }
    
    // MARK: - UI
    public lazy var metricsViewController : MetricsScreen = {
        let controller = MetricsScreen()
        controller.minimumOpeningHeight = minOpeningHeight
        controller.delegate = self
        controller.measurementFormatter = measurementFormatter
        controller.storeManager = storeManager
        return controller
    }()
    
    private lazy var confettiView : ConfettiView = {
        let view = ConfettiView(frame: view.frame )
        return view
    }()
    
    private lazy var stepProgressView : StepProgressView = {
        let view = StepProgressView(max: self.dailyStepGoal)
        return view
    }()
    
    private let stairsClimbedSection = InfoSection(
        icon: UIImage(
            systemName: "arrow.up.right",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
        body: "\(0)",
        detail: "Floors Climbed")
    
    private let distanceTraveledSection =  InfoSection(
        icon: UIImage(
            systemName: "figure.walk",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
        body: "\(0)",
        detail: "Distance Traveled")
    
    private let dateSection =  InfoSection(
        icon: UIImage(
            systemName: "calendar",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
        body: "Today",
        detail: "Date")
    
    private lazy var infoRow : InfoRow = {
        let view = InfoRow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "E d"
        return formatter
    }()
    
    // MARK: - Life cycle
    init(pedometerManager: PedometerManager, settingsManager: SettingsManager, storeManager: StoreManager){
        self.pedometerManager = pedometerManager
        self.settingsManager = settingsManager
        self.storeManager = storeManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        
        
        // additional config
        configureMetricsViewController()
        
        // listen to changes
        listenToSettingChanges()
        
        // listen to progress
        listenToProgess()
    }
}

// MARK: - Config
private extension HomeScreen {
    private func configureViewController() {
        view.backgroundColor = .systemGray6
    }
    
    private func configureProgressView() {
        stepProgressView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureMetricsViewController() {
        add(metricsViewController, frame: CGRectMake(0, view.frame.maxY - minOpeningHeight, view.frame.width, view.frame.height))
    }
}

// MARK: - Layout
private extension HomeScreen {
    private func layoutViews() {
        view.addSubview(stepProgressView)
        view.addSubview(infoRow)
        view.addSubview(confettiView)
        
        infoRow.addSections([dateSection, distanceTraveledSection, stairsClimbedSection])
        
        NSLayoutConstraint.activate([
            stepProgressView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            stepProgressView.widthAnchor.constraint(equalTo: view.widthAnchor),
            stepProgressView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40),
            stepProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoRow.topAnchor.constraint(equalToSystemSpacingBelow: stepProgressView.bottomAnchor, multiplier: 2),
            infoRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: - Public Methods {
extension HomeScreen {
    public func startUpdatingLiveSteps() {
        print(#function)
        pedometerManager?.startLiveUpdates()
        
        stepDataCancellable = pedometerManager?
            .currentPedometerData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { pedometerData in
                self.currentStepData = pedometerData
            })
    }
    
    public func stopUpdatingSteps() {
        print(#function)
        pedometerManager?.stopLiveUpdates()
    }
}
// MARK: - Private Methods
private extension HomeScreen {
    private func listenToProgess() {
        stepProgressView
            .didReachMax
            .compactMap({$0})
            .sink { completedStepData in
                self.updateCompletion(completedStepData)
            }
            .store(in: &cancellables)
    }
    
    private func listenToSettingChanges() {
        settingsManager?
            .dailyStepGoal
            .sink(receiveValue: { dailyStepGoal in
                self.dailyStepGoal = dailyStepGoal
            })
            .store(in: &cancellables)
        
        settingsManager?
            .preferMetricUnits
            .sink(receiveValue: { preferMetricUnits in
                self.unitDistance = preferMetricUnits ? .kilometers : .miles
            })
            .store(in: &cancellables)
    }
    
    private func resetViewsToZero()  {
        self.updateStepProgress(nil)
        self.updateFloorsClimbed(0)
        self.updateDistanceTraveled(0)
        self.updateDateSelected(.now)
    }
    
    private func update(_ pedometerData: CMPedometerData?) {
        guard let pedometerData = pedometerData else {
            self.resetViewsToZero()
            return
        }
        
        self.updateStepProgress(pedometerData)
        self.updateFloorsClimbed(pedometerData.floorsAscended)
        self.updateDistanceTraveled(pedometerData.distance)
        self.updateDateSelected(pedometerData.startDate)
    }
    
    private func updateForLastSevenDays() {
        weeklydataCancellable = pedometerManager?
            .getStepsForLastSevenDays()
            .receive(on: DispatchQueue.main)
            .map({ weeklyData in
                for day in weeklyData {
                    if day.numberOfSteps.intValue >= self.dailyStepGoal {
                        self.updateCompletion(day)
                    }
                }
                
                return weeklyData
            })
            .sink(receiveCompletion: { _ in
            }, receiveValue: { weeklyStepData in
                self.weeklyStepData = weeklyStepData
            })
    }
    
    private func updateStepProgress(_ pedometerData: CMPedometerData?) {
        stepProgressView.updateData(with: pedometerData)
    }
    
    private func updateFloorsClimbed(_ value: NSNumber?) {
        stairsClimbedSection.updateBodyLabel("\(value ?? 0.0)")
    }
    
    private func updateDateSelected(_ date: Date) {
        if Calendar.current.isDateInToday(date) {
            dateSection.updateBodyLabel("Today")
        } else if Calendar.current.isDateInYesterday(date){
            dateSection.updateBodyLabel("Yesterday")
        } else {
            dateSection.updateBodyLabel(dateFormatter.string(from: date))
        }
    }
    
    private func updateDistanceTraveled(_ value: NSNumber?, preferMetricUnits: Bool? = false) {
        guard let distanceInMeters = value else { return }
        
        let distance = Measurement<UnitLength>(value: distanceInMeters.doubleValue, unit: .meters).converted(to: unitDistance)
        let formattedDistance = measurementFormatter.string(from: distance)
        
        distanceTraveledSection.updateBodyLabel(formattedDistance)
    }
    
    private func updateCompletion(_ pedometerData: CMPedometerData) {
        guard let context = storeManager?.managedContext else { return }
        
        let entry = Entry.findOrInsert(pedometerData.startDate, in: context)
        
        // The entry doesn't exist yet
        if entry.objectID.isTemporaryID || !entry.didComplete {
            entry.didComplete = true
            entry.date = pedometerData.startDate
            
            storeManager?.save()
        }
    }
}

// MARK: - Metrics Delegate
extension HomeScreen: MetricsDelegate {
    func provideWeeklyData(_ viewController: UIViewController) {
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

