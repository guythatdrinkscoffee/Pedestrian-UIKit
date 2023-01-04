//
//  MetricsViewController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit
import CoreMotion
import Charts

class MetricsViewController: UIViewController {
    // MARK: - Properties
    fileprivate enum DrawerState {
        case compact
        case open
    }
    
    public var minimumHeight: CGFloat = 0.0
    
    public var limit : Double = 10000
    
    private var fullHeight: CGFloat {
        let safeArea = self.parent?.view.safeAreaInsets.top
        return (self.parent?.view.frame.height ?? 0.0) - (safeArea ?? 0.0)
    }
    
    private var safeAreaBottomHeight: CGFloat {
        return (self.parent?.view.safeAreaInsets.bottom) ?? 0.0
    }
    
    private var settingsButtonHeight: CGFloat {
        return settingsButton.frame.height
    }
    
    private lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private var state: DrawerState = .compact
    
    private var animationDuration: TimeInterval = 0.6
    
    weak var delegate: MetricsDelegate?
    
    
    // MARK: - UI
    private lazy var actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage(
                systemName: "chevron.compact.up",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)), for: .normal)
        button.addTarget(self, action: #selector(handleActionTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray
        return button
    }()

    private lazy var settingsButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage(
                systemName: "gearshape.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)), for: .normal)
        button.addTarget(self, action: #selector(handleSettingsTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray
        return button
    }()
    
    private lazy var limitLine : ChartLimitLine = {
        let line = ChartLimitLine(limit: limit, label: String(format: "%.0f", limit))
        line.valueFont = .monospacedSystemFont(ofSize: 12 , weight: .bold)
        line.lineColor = .systemTeal
        line.labelPosition = .rightTop
        line.valueTextColor = UIColor.systemTeal
        line.lineDashLengths = [8.0, 6.0]
        return line
    }()
    
    private lazy var barChart : BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.pinchZoomEnabled = false
        chart.setScaleEnabled(false)
        chart.doubleTapToZoomEnabled = false
        chart.delegate = self
    
        // chart highlight
        chart.highlightPerDragEnabled = false
    
        // chart left axis
        let leftAxis = chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = limit * 1.5
        leftAxis.addLimitLine(limitLine)
        
        // chart right axis
        let rightAxis = chart.rightAxis
        rightAxis.enabled = false
        
        // chart x-axis
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .semibold)
        xAxis.drawGridLinesEnabled = false
        
        // chart custom legend
        let goalEntry = LegendEntry(label: "Daily Goal")
        goalEntry.formColor = .systemTeal
        goalEntry.form = .line
        
        let infoEntry = LegendEntry(label: "Last 7 Days")
        infoEntry.formColor = .systemPink
        infoEntry.form = .square
        
        let legend = chart.legend
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .left
        legend.setCustom(entries: [infoEntry, goalEntry])
        
        return chart
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
        
        self.delegate?.provideWeeklyData(self)
    }
}

// MARK: - Config
private extension MetricsViewController {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
    }
}

// MARK: - Layout
private extension MetricsViewController {
    private func layoutViews(){
        view.addSubview(actionButton)
        view.addSubview(settingsButton)
        view.addSubview(barChart)

        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            settingsButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            barChart.topAnchor.constraint(equalToSystemSpacingBelow: settingsButton.bottomAnchor, multiplier: 1.5),
            barChart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barChart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barChart.heightAnchor.constraint(
                equalToConstant: minimumHeight - ((safeAreaBottomHeight + settingsButtonHeight) * 2.0))
        ])
    }
}

// MARK: - Public Methods
extension MetricsViewController {
    public func updateMetrics(_ data: [CMPedometerData]) {
        var dataEntries: [BarChartDataEntry] = []
        
        let timeStamps : [TimeInterval] = data.map({$0.startDate.timeIntervalSince1970})
        
        for i in 0..<data.count {
            let steps = data[i].numberOfSteps.doubleValue
            let newEntry = BarChartDataEntry(x: Double(i), y: steps)
            dataEntries.append(newEntry)
        }
        
        barChart.xAxis.valueFormatter = XAxisChartFormatter(dateFormatter: dateFormatter, timestamps: timeStamps)
    
        let dataSet = BarChartDataSet(entries: dataEntries)
        dataSet.valueFont = .monospacedSystemFont(ofSize: 12, weight: .bold)
        dataSet.barShadowColor = .black
        dataSet.setColor(UIColor.systemPink)
        
        let chartData = BarChartData(dataSet: dataSet)

        barChart.data = chartData
        barChart.notifyDataSetChanged()
    }
    
    
    public func resetSelection() {
        chartValueNothingSelected(barChart)
        barChart.highlightValue(nil)
    }
}

// MARK: - Private Methods
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
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            if sender.transform == .identity {
                sender.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.999))
            } else {
                sender.transform = .identity
            }
        })
    }
    
    @objc
    private func handleSettingsTap(_ sender: UIButton){
        let containerNav = UINavigationController(rootViewController: SettingsViewController())
        present(containerNav, animated: true)
    }
    
    private func snapTo(height: CGFloat) {
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            let frame = self.view.frame
            self.view.frame = CGRectMake(0, frame.height - height, frame.width, frame.height)
        }
    }

}

// MARK: - ChartView Delegate
extension MetricsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        self.delegate?.updateSelection(with: Int(entry.x))
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        self.delegate?.updateSelection(with: nil)
    }
}

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
