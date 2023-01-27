//
//  MetricsViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit
import CoreMotion
import Charts
import SwiftUI

class MetricsScreen: UIViewController {
    // MARK: - Public Properties
    // This height is set by the calling view controller that
    // is presenting this view and is assigned to the
    // view's height when first displayed
    public var minimumOpeningHeight: CGFloat = 0.0
    
    // The measurement formatter that is passed by the parent view controller
    public var measurementFormatter: MeasurementFormatter?

    // MARK: - Private Properties
    
    // This height is the allowed minimum chart height
    // after considering the heights of the parent's
    // safeAreaBottomHeight and the settings button
    private var minimumChartHeight: CGFloat {
        return  minimumOpeningHeight - ((safeAreaBottomHeight + settingsButtonHeight) * 2.0)
    }
    
    // This height the maximum height allowed
    // for the current view after considering the
    // parent's height minus the top safe area
    private var maxOpeningHeight: CGFloat {
        return (self.parent?.view.frame.height ?? 0.0) - safeAreaTopHeight
    }
    
    // Bottom safe area height of the parent view controller
    private var safeAreaBottomHeight: CGFloat {
        return (self.parent?.view.safeAreaInsets.bottom) ?? 0.0
    }
    
    // Top safe area height of the parent view controller
    private var safeAreaTopHeight: CGFloat {
        return (self.parent?.view.safeAreaInsets.top) ?? 0.0
    }
    
    // The height of the settings button
    private var settingsButtonHeight: CGFloat {
        return settingsButton.frame.height
    }
    
    // date formatter
    private lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private var settingsManager: SettingsManager?
    
    private var animationDuration: TimeInterval = 0.6
    
    private var origin: CGPoint = .zero
    
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    private var sections: [MetricsSection] = []
    
    private var tintColor: UIColor = .systemTeal
        
    
    // The max limit value which corresponds
    // to the daily user's step goal
    private var stepGoal : Double = 10_000
    
    // The weekly step data returned by the parent
    // view controller
    private var data: [CMPedometerData] = [] {
        didSet {
            updateData(data)
        }
    }
    
    // MARK: - UI
    private lazy var dragIndicator : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingsButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.settings, for: .normal)
        button.addTarget(self, action: #selector(handleSettingsTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray
        return button
    }()
    
    private lazy var limitLine : ChartLimitLine = {
        let line = ChartLimitLine(limit: stepGoal)
        line.valueFont = .monospacedSystemFont(ofSize: 12 , weight: .bold)
        line.lineColor = tintColor
        line.valueTextColor = tintColor
        line.lineWidth = 3
        line.lineDashLengths = [8.0, 6.0]
        return line
    }()
    
    // chart custom legend
    private lazy var goalEntry : LegendEntry = {
        // chart custom legend
        let goalEntry = LegendEntry(label: "Daily Step Goal")
        goalEntry.formColor = tintColor
        goalEntry.form = .line
        return goalEntry
    }()
    
    private lazy var barChart : BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.pinchZoomEnabled = false
        chart.setScaleEnabled(false)
        chart.doubleTapToZoomEnabled = false
        chart.isUserInteractionEnabled = false
        chart.delegate = self
        
        // chart highlight
        chart.highlightPerDragEnabled = false
        
        // chart left axis
        let leftAxis = chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.gridColor = .systemGray4
        leftAxis.addLimitLine(limitLine)
        
        // chart right axis
        let rightAxis = chart.rightAxis
        rightAxis.enabled = false
        
        // chart x-axis
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .semibold)
        xAxis.drawGridLinesEnabled = false
        
        let legend = chart.legend
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .left
        legend.setCustom(entries: [goalEntry])
        
        //animation
        chart.animate(yAxisDuration: 0.3, easingOption: .linear)
        
        return chart
    }()
    
    private lazy var panGesture : UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture(_:)))
        return gesture
    }()
    
    private lazy var stepMetricsController : MetricsController = {
        let controller = MetricsController(settingsManager: settingsManager)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    private lazy var streaksMetricsController : MetricsController = {
        let controller = MetricsController(settingsManager: settingsManager)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    // MARK: - Life cycle
    init(_ settingsManager: SettingsManager? = nil){
        super.init(nibName: nil, bundle: nil)
        self.settingsManager = settingsManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config
        configureViewController()
        
        // layout
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update the origin point for the view
        origin = view.frame.origin
        
        // Update the streaks controller
        updateStreaksController()
    }
}

// MARK: - Config
private extension MetricsScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
    }
}

// MARK: - Layout
private extension MetricsScreen {
    private func layoutViews(){
        view.addSubview(dragIndicator)
        view.addSubview(settingsButton)
        view.addSubview(barChart)
        view.addGestureRecognizer(panGesture)
        
        add(stepMetricsController)
        add(streaksMetricsController)
        
        NSLayoutConstraint.activate([
            dragIndicator.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            dragIndicator.heightAnchor.constraint(equalToConstant: 5),
            dragIndicator.widthAnchor.constraint(equalToConstant: 35),
            dragIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            settingsButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            barChart.topAnchor.constraint(equalToSystemSpacingBelow: settingsButton.bottomAnchor, multiplier: 1.5),
            barChart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barChart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barChart.heightAnchor.constraint(equalToConstant: minimumChartHeight),
            
            stepMetricsController.view.topAnchor.constraint(equalTo: barChart.bottomAnchor, constant: safeAreaBottomHeight),
            stepMetricsController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            stepMetricsController.view.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stepMetricsController.view.trailingAnchor, multiplier: 2),
            
            streaksMetricsController.view.topAnchor.constraint(equalToSystemSpacingBelow: stepMetricsController.view.bottomAnchor, multiplier: 2),
            streaksMetricsController.view.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            streaksMetricsController.view.heightAnchor.constraint(equalToConstant: 150),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: streaksMetricsController.view.trailingAnchor, multiplier: 2),
        ])
    }
}

// MARK: - Public Methods
extension MetricsScreen {
    public func setData(data: [CMPedometerData]) {
        self.data = data
        self.stepMetricsController.setData(data)
    }
    
    public func setStepGoal(_ goal: Int){
        self.stepGoal = Double(goal)
        self.updateData(data)
    }
    
    public func reloadMetricsController() {
        if let highlighted = barChart.highlighted.first,
           let data = barChart.data?.entry(for: highlighted)?.data as? CMPedometerData {
            self.stepMetricsController.setData([data], for: .selection(data.startDate))
        } else {
            self.stepMetricsController.setData(data)
        }
    }
}

// MARK: - Private Methods
private extension MetricsScreen { 
    
    @objc
    private func handleSettingsTap(_ sender: UIButton){
        let settingsScreen = SettingsScreen(settingsManager)
        let navigationContainer = UINavigationController(rootViewController: settingsScreen)
        present(navigationContainer, animated: true)
    }
    
    @objc func handleDragGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let view = self.view else { return }
        
        /// get references to the views min height, width and height
        let y = view.frame.minY
        let width = view.frame.width
        let height = view.frame.height
        
        // get a reference to the translation
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        // check if the translation is greater than or less than the full and minimum heights allowed
        if translation.y + y >= origin.y {
            return
        } else if translation.y + y <= safeAreaTopHeight {
            return
        }
        
        // handle the recognizer state
        switch recognizer.state {
        case .began, .changed:
            // init the feedback generator
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator?.prepare()
            
            // set the new frame for the view
            view.frame = CGRect(x: .zero, y: y + translation.y, width: width, height: height)
            
            //reset the translation
            recognizer.setTranslation(.zero, in: view)
        case .ended:
            feedbackGenerator?.impactOccurred()
            
            if velocity.y >= 0 {
                snapTo(height: minimumOpeningHeight)
                barChart.isUserInteractionEnabled = false
                barChart.highlightValue(nil)
                chartValueNothingSelected(barChart)
            } else {
                snapTo(height: maxOpeningHeight)
                barChart.isUserInteractionEnabled = true
            }
            
        default : break
        }
        
    }
    
    private func updateData(_ data: [CMPedometerData]) {
        var dataEntries: [BarChartDataEntry] = []
        let maxDataPoint = data.max(by: {$0.numberOfSteps.intValue < $1.numberOfSteps.intValue})
        let timeStamps : [TimeInterval] = data.map({$0.endDate.timeIntervalSince1970})
        
        for i in 0..<data.count {
            let steps = data[i].numberOfSteps.doubleValue
            let newEntry = BarChartDataEntry(x: Double(i), y: steps, data: data[i])
            dataEntries.append(newEntry)
        }
        
        barChart.xAxis.valueFormatter = XAxisChartFormatter(dateFormatter: dateFormatter, timestamps: timeStamps)
        limitLine.limit = stepGoal
        if let maxDataPoint = maxDataPoint {
            let maxSteps = maxDataPoint.numberOfSteps.doubleValue
            barChart.leftAxis.axisMaximum = maxSteps < stepGoal ? stepGoal * 1.2 : maxSteps * 1.5
        } else {
            barChart.leftAxis.axisMaximum = stepGoal * 2
        }
        
        let dataSet = BarChartDataSet(entries: dataEntries)
        dataSet.valueFont = .monospacedSystemFont(ofSize: 12, weight: .bold)
        dataSet.setColor(.systemPink)
        
        let chartData = BarChartData(dataSet: dataSet)
        
        barChart.data = chartData
        barChart.notifyDataSetChanged()
    }
    
    private func snapTo(height: CGFloat) {
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
            let frame = self.view.frame
            self.view.frame = CGRectMake(0, frame.height - height, frame.width, frame.height)
        }
    }
    
    private func updateStreaksController() {
        let (current, max) = PersistenceManager.shared.getCurrentStreak()
        
        let currentStreak = current.isMultiple(of: 2) ? "\(current) days"  : "\(current) day"
        let maxStreak = max.isMultiple(of: 2) ? "\(max) days"  : "\(max) day"
        
        // update the streaks controller
        self.streaksMetricsController.setMetrics([
            .init(title: "Streaks", metrics: [
                .init(title: "Current Streak", value: currentStreak, icon: UIImage(systemName: "flame.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.systemOrange]))),
                .init(title: "Longest Streak", value: maxStreak, icon: UIImage(systemName: "flag.filled.and.flag.crossed"))
            ], height: 80)
        ])
    }
}

// MARK: - ChartView Delegate
extension MetricsScreen: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let pedometerData = entry.data as? CMPedometerData else {
            return
        }
        
        self.stepMetricsController.setData([pedometerData],for: .selection(pedometerData.startDate))
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        self.stepMetricsController.setData(data, for: .lastSixDays)
    }
}

// MARK: - XAxisChartFormatter
class XAxisChartFormatter: IndexAxisValueFormatter {
    private var dateFormatter : DateFormatter?
    private var timestamps: [TimeInterval]?
    
    convenience init(dateFormatter: DateFormatter, timestamps: [TimeInterval]) {
        self.init()
        self.dateFormatter = dateFormatter
        self.timestamps = timestamps
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter, let intervals = timestamps else { return ""}
        
        let date = Date(timeIntervalSince1970: intervals[Int(value)])
        return dateFormatter.string(from: date)
    }
}
