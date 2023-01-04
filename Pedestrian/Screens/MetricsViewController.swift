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
    
    // This height is set by the calling view controller that
    // is presenting this view and is assigned to the
    // view's height when first displayed
    public var minimumOpeningHeight: CGFloat = 0.0
    
    // This height is the allowed minimum chart height
    // after considering the heights of the parent's
    // safeAreaBottomHeight and the settings button
    private var minimumChartHeight: CGFloat {
        return  minimumOpeningHeight - ((safeAreaBottomHeight + settingsButtonHeight) * 2.0)
    }
    
    // The max limit value which corresponds
    // to the daily user's step goal
    public var limit : Double = 10000
    
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
    
    private lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private var state: DrawerState = .compact
    
    private var animationDuration: TimeInterval = 0.6
    
    private var origin: CGPoint = .zero
    
    private var feedbackGenerator: UISelectionFeedbackGenerator?
    
    weak var delegate: MetricsDelegate?
    
    
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
        
        self.delegate?.provideWeeklyData(self)
        
        print(safeAreaTopHeight)
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
        view.addSubview(dragIndicator)
        view.addSubview(settingsButton)
        view.addSubview(barChart)
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
            barChart.heightAnchor.constraint(equalToConstant: minimumChartHeight)
        ])
    }
}

// MARK: - Public Methods
extension MetricsViewController {
    public func updateMetrics(_ data: [CMPedometerData]) {
        var dataEntries: [BarChartDataEntry] = []
        let maxDataPoint = data.max(by: {$0.numberOfSteps.intValue < $1.numberOfSteps.intValue})
        let timeStamps : [TimeInterval] = data.map({$0.startDate.timeIntervalSince1970})
        
        for i in 0..<data.count {
            let steps = data[i].numberOfSteps.doubleValue
            let newEntry = BarChartDataEntry(x: Double(i), y: steps)
            dataEntries.append(newEntry)
        }
        
        barChart.xAxis.valueFormatter = XAxisChartFormatter(dateFormatter: dateFormatter, timestamps: timeStamps)
        
        if let maxDataPoint = maxDataPoint {
            let maxSteps = maxDataPoint.numberOfSteps.doubleValue
            barChart.leftAxis.axisMaximum = maxSteps < limit ? limit : maxSteps * 1.5
        } else {
            barChart.leftAxis.axisMaximum = limit * 2
        }
            
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
    private func handleSettingsTap(_ sender: UIButton){
        let containerNav = UINavigationController(rootViewController: SettingsViewController())
        present(containerNav, animated: true)
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
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
            
            // set the new frame for the view
            view.frame = CGRect(x: .zero, y: y + translation.y, width: width, height: height)
            
            //reset the translation
            recognizer.setTranslation(.zero, in: view)
        case .ended:
            feedbackGenerator?.selectionChanged()
            
            if velocity.y >= 0 {
                snapTo(height: minimumOpeningHeight)
            } else {
                snapTo(height: maxOpeningHeight)
            }
        default : break
        }
        
    }
    
    private func snapTo(height: CGFloat) {
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
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
