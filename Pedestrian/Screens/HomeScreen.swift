//
//  HomeViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 12/31/22.
//

import UIKit
import Combine
import CoreMotion

class HomeScreen: UIViewController {
    // MARK: - Private Properties
    private var pedometerManager: PedometerManager?
    
    private var settingsManager: SettingsManager?
    
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
    
    private lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "E, MMM d"
        return formatter
    }()
    
    private var minOpeningHeight: CGFloat {
        // height of system spacing
        let systemSpacing: CGFloat = 8.0
        
        // total height of the view's frame
        let height = view.frame.height
        
        // height of the title label
        let titleLabelHeight = titleLabel.frame.height + (systemSpacing * 1.2)
        
        // height of the progress view
        let progressViewHeight = stepProgressView.frame.height + (systemSpacing)
        
        // height of the infoRow stack view
        let infoRowViewHeight = infoRow.frame.height + (systemSpacing * 2.5)
        
        // height of the top safe area
        let viewSafeAreaTop = view.safeAreaInsets.top
        
        // padding from bottom
        let paddingFromBottom: CGFloat = 15
        
        return height - (titleLabelHeight + progressViewHeight + infoRowViewHeight + viewSafeAreaTop + paddingFromBottom)
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
    
    private var showConfetti : Bool = true
    // MARK: - UI
    public lazy var metricsViewController : MetricsScreen = {
        let controller = MetricsScreen()
        controller.minimumOpeningHeight = minOpeningHeight
        controller.measurementFormatter = measurementFormatter
        return controller
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confettiView : ConfettiView = {
        let view = ConfettiView(frame: view.frame )
        return view
    }()
    
    private lazy var stepProgressView : StepProgressView = {
        let view = StepProgressView(max: 4000)
        view.setProgressColor(.systemTeal)
        return view
    }()
    
    private let stairsAscendedSection = InfoSection(
        icon: .arrowUp,
        body: "\(0)",
        detail: "Floors Ascended")
    
    private let stairsDescendedSection = InfoSection(
        icon: .arrowDown,
        body: "\(0)",
        detail: "Floors Descended")
    
    private let distanceTraveledSection =  InfoSection(
        icon: .walking,
        body: "\(0)",
        detail: "Distance Traveled")
    
    private lazy var infoRow : InfoRow = {
        let view = InfoRow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Life cycle
    init(pedometerManager: PedometerManager, settingsManager: SettingsManager){
        self.pedometerManager = pedometerManager
        self.settingsManager = settingsManager
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
        
        // Add a new day observer
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(handleNewDay(_:)), name: .NSCalendarDayChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // additional config
        configureMetricsViewController()
        
        // listen to progress
        listenToProgess()
        
        // request steps for week
        updateForLastSevenDays()
    }
}

// MARK: - Config
private extension HomeScreen {
    private func configureViewController() {
        view.backgroundColor = .systemGray6
        self.titleLabel.text = self.dateFormatter.string(from: .now)
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
        view.addSubview(titleLabel)
        view.addSubview(stepProgressView)
        view.addSubview(infoRow)
        view.addSubview(confettiView)
        
        infoRow.addSections([distanceTraveledSection, stairsAscendedSection, stairsDescendedSection])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.2),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            titleLabel.heightAnchor.constraint(equalToConstant: 35),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stepProgressView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
            stepProgressView.widthAnchor.constraint(equalTo: view.widthAnchor),
            stepProgressView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            stepProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoRow.topAnchor.constraint(equalToSystemSpacingBelow: stepProgressView.bottomAnchor, multiplier: 3),
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
            .sink { didComplete in
                if  didComplete {
                    self.updateCompletionForCurrentStepData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func resetViewsToZero()  {
        self.updateStepProgress(nil)
        self.updatedFloorsAscended(0)
        self.updateDistanceTraveled(0)
    }
    
    private func update(_ pedometerData: CMPedometerData?) {
        guard let pedometerData = pedometerData else {
            self.resetViewsToZero()
            return
        }
        
        self.updateStepProgress(pedometerData)
        self.updatedFloorsAscended(pedometerData.floorsAscended)
        self.updateDistanceTraveled(pedometerData.distance)
        self.updateFloorsDescended(pedometerData.floorsDescended)
    }
    
    private func updateForLastSevenDays() {
        weeklydataCancellable = pedometerManager?
            .getStepsForLastSevenDays()
            .receive(on: DispatchQueue.main)
            .map({ weeklyPedometerData in
                for pedometerData in weeklyPedometerData {
                    self.shouldSave(pedometerData)
                }
                return weeklyPedometerData
            })
            .sink(receiveCompletion: { _ in
            }, receiveValue: { weeklyStepData in
                self.weeklyStepData = weeklyStepData
            })
    }

    private func updateStepProgress(_ pedometerData: CMPedometerData?) {
        guard let pedometerData = pedometerData else {
            stepProgressView.updateValue(-1)
            return
        }
        stepProgressView.updateValue(pedometerData.numberOfSteps.intValue)
    }
    
    private func shouldSave(_ pedometerData: CMPedometerData) {
        PersistenceManager.shared.save(pedometerData)
    }
    
    private func updatedFloorsAscended(_ value: NSNumber?) {
        stairsAscendedSection.updateBodyLabel("\(value ?? 0.0)")
    }
    
    private func updateFloorsDescended(_ value: NSNumber?){
        stairsDescendedSection.updateBodyLabel("\(value ?? 0.0)")
    }
    
    private func updateDistanceTraveled(_ value: NSNumber?, preferMetricUnits: Bool? = false) {
        guard let distanceInMeters = value else { return }
        
        let distance = Measurement<UnitLength>(value: distanceInMeters.doubleValue, unit: .meters).converted(to: .kilometers)
        let formattedDistance = measurementFormatter.string(from: distance)
        
        distanceTraveledSection.updateBodyLabel(formattedDistance)
    }
    
    private func updateCompletionForCurrentStepData() {
        if showConfetti {
            confettiView.startConfetti()
            showConfetti = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.confettiView.stopConfetti()
            }
        }
    }
    
    @objc
    private func handleNewDay(_ notification: NSNotification) {
        if let currentStepData = currentStepData {
            if !Calendar.current.isDateInToday(currentStepData.startDate)
                || !Calendar.current.isDateInToday(currentStepData.endDate){
                
                DispatchQueue.main.async {
                    self.currentStepData = nil
                    self.titleLabel.text = self.dateFormatter.string(from: .now)
                    self.updateForLastSevenDays()
                }
            }
        }
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

 
