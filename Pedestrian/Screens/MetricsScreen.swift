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
    
    
    // The max limit value which corresponds
    // to the daily user's step goal
    public var stepGoal : Double = 4_000
    
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
    
    private var lifetimeStartDate: Date = .now
    
    private var animationDuration: TimeInterval = 0.6
    
    private var origin: CGPoint = .zero
    
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    private var sections: [MetricsSection] = []
    
    private var tintColor: UIColor = .systemTeal
        
    private var data: [CMPedometerData] = [] {
        didSet {
            updateData(data)
            aggregateData(data)
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
    
    private lazy var metricsCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(InfoCell.self, forCellWithReuseIdentifier: InfoCell.resuseIdentifier)
        collectionView.register(ReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReusableHeaderView.reuseIdentifier)
        collectionView.register(ReusableFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ReusableFooterView.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var panGesture : UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture(_:)))
        return gesture
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
        
        origin = view.frame.origin
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
        view.addSubview(metricsCollectionView)
        view.addGestureRecognizer(panGesture)
        
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
            
            metricsCollectionView.topAnchor.constraint(equalTo: barChart.bottomAnchor, constant: safeAreaBottomHeight),
            metricsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metricsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metricsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -safeAreaBottomHeight)
        ])
    }
}

// MARK: - Public Methods
extension MetricsScreen {
    public func setData(data: [CMPedometerData]) {
        self.data = data
    }
}

// MARK: - Private Methods
private extension MetricsScreen {
    
    @objc
    private func handleSettingsTap(_ sender: UIButton){
        let settingsScreen = SettingsScreen()
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
    
    private func aggregateData(_ data: [CMPedometerData]) {
       
        sections = [
            aggregateCurrentData(data),
            aggregateLifeTimeData()
        ]
        
        metricsCollectionView.reloadData()
    }
    
    private func aggregateCurrentData(_ data: [CMPedometerData]) -> MetricsSection {
        let steps = data.reduce(0, {$0 + $1.numberOfSteps.intValue })
        let distance = data.reduce(0.0, {$0 + ($1.distance?.doubleValue ?? 0.0) })
        let floorsAscended = data.reduce(0, {$0 + ($1.floorsAscended?.intValue ?? 0)})
        let floorsDescended = data.reduce(0, {$0 + ($1.floorsDescended?.intValue ?? 0)})
        
        let distanceInLength = Measurement<UnitLength>(value: distance, unit: .meters).converted(to: .kilometers)
        let distanceString = measurementFormatter?.string(from: distanceInLength)
        
        
        let weeklyData = MetricsSection(title: "Last 7 Days", data: [
            .init(description: "Step Count", value: steps.formatted(.number)),
            .init(description: "Distance Traveled", value: distanceString),
            .init(description: "Floors Ascended", value: floorsAscended),
            .init(description: "Floors Descended", value: floorsDescended)
        ])
        
        return weeklyData
    }
    
    private func aggregateForSelection(_ data: CMPedometerData) {
        let dateString = data.endDate
            .formatted(
                .dateTime
                .month(.abbreviated)
                .weekday(.wide)
                .day(.twoDigits))
        
        let distanceInLength = Measurement<UnitLength>(value: data.distance?.doubleValue ?? 0.0, unit: .meters).converted(to: .kilometers)
        let distanceString = measurementFormatter?.string(from: distanceInLength)
        
        sections[0] = MetricsSection(title: dateString, data: [
            .init(description: "Step Count", value: data.numberOfSteps.intValue.formatted(.number)),
                .init(description: "Distance Traveled", value: distanceString),
                .init(description: "Floors Ascended", value: data.floorsAscended),
                .init(description: "Floors Descended", value: data.floorsDescended)
            ])
        
        metricsCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    private func aggregateLifeTimeData() -> MetricsSection {
        let allEntries = PersistenceManager.shared.getAll()
        let totalSteps = allEntries.reduce(0, {$0 + $1.numberOfSteps})
        let totalDistanceInMeters = allEntries.reduce(0.0, {$0 + $1.distanceInMeters})
        
        let distanceInLength = Measurement<UnitLength>(value: totalDistanceInMeters, unit: .meters).converted(to: .kilometers)
        let distanceString = measurementFormatter?.string(from: distanceInLength)
        
        let lifetimeSection = MetricsSection(title: "Lifetime Totals", data: [
            .init(icon: .crown, description: "Step Count", value: totalSteps.formatted(.number), color: .systemTeal),
            .init(icon: .walking, description: "Distance Traveled", value: distanceString, color: .systemTeal)
        ])
        
        if let firstStepDay = allEntries.first?.startDate {
            self.lifetimeStartDate = firstStepDay
        }
        
        return lifetimeSection
    }
    
    private func resetSelection() {
        sections[0] = aggregateCurrentData(self.data)
        metricsCollectionView.reloadSections(IndexSet(integer: 0))
    }
}

// MARK: - ChartView Delegate
extension MetricsScreen: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let pedometerData = entry.data as? CMPedometerData {
            aggregateForSelection(pedometerData)
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        resetSelection()
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

// MARK: - UICollectionViewDataSource
extension MetricsScreen: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCell.resuseIdentifier, for: indexPath) as? InfoCell else {
            fatalError("failed to dequeue a resuable cell")
        }
        
        let dataPoint = sections[indexPath.section].data[indexPath.row]
        cell.data = dataPoint
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReusableHeaderView.reuseIdentifier, for: indexPath)
            
            guard let titledHeader = header as? ReusableHeaderView else {
                return header
            }
            let title = sections[indexPath.section].title
            titledHeader.configure(with: title)
            return titledHeader
        case UICollectionView.elementKindSectionFooter :
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReusableFooterView.reuseIdentifier, for: indexPath)
            
            guard let titledFooter = footer as? ReusableFooterView else {
                return footer
            }
            
            if indexPath.section == 1 {
                let title = lifetimeStartDate
                    .formatted(
                        .dateTime
                        .month()
                        .weekday()
                        .day()
                        .year())

                titledFooter.configure(with: "Since \(title)")
            }
            
            return titledFooter
        default:
            fatalError("reusable header of \(kind) is not yet supported")
        }
    }
    
    
}

// MARK: - UICollectionView Delegate
extension MetricsScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return section == 0 ? .zero : CGSize(width: view.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.height, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = view.bounds.width
        let padding: CGFloat = 10
        let itemSpacing: CGFloat = 10
        
        let availableWidth = totalWidth - (padding * 2) - (itemSpacing)
        
        let itemWidth = availableWidth / 2
        
        return  CGSize(width: itemWidth, height: 80)
    }
}
