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
        return (self.parent?.view.frame.height ?? 0.0) * 1
    }
    
    private var safeAreaBottomHeight: CGFloat {
        return (self.parent?.view.safeAreaInsets.bottom) ?? 0.0
    }
    
    private var actionBarHeight: CGFloat {
        return actionButton.frame.height
    }
    
    private lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private var state: DrawerState = .compact
    
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
        return button
    }()
    
    private lazy var limitLine : ChartLimitLine = {
        let line = ChartLimitLine()
        line.limit = limit
        line.lineColor = .systemPink
        line.labelPosition = .rightTop
        line.lineDashLengths = [8.0, 6.0]
        return line
    }()
    
    private lazy var barChart : BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.pinchZoomEnabled = false
        chart.setScaleEnabled(false)
        chart.doubleTapToZoomEnabled = false
        
        // chart highlight
        chart.highlightPerDragEnabled = false
    
        // chart left axis
        let leftAxis = chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        
        // chart right axis
        let rightAxis = chart.rightAxis
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLimitLinesBehindDataEnabled = true
        rightAxis.addLimitLine(limitLine)
        
        // chart x-axis
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .semibold)
        xAxis.drawGridLinesEnabled = false
//        xAxis.drawAxisLineEnabled = false
        
        // chart custom legend
        let goalEntry = LegendEntry(label: "Daily Goal")
        goalEntry.formColor = .systemPink
        goalEntry.form = .line
        
        let legend = chart.legend
        legend.verticalAlignment = .top
        legend.setCustom(entries: [goalEntry])
        
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
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 15
    }
}

// MARK: - Layout
private extension MetricsViewController {
    private func layoutViews(){
        view.addSubview(actionButton)
        view.addSubview(barChart)
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            barChart.topAnchor.constraint(equalToSystemSpacingBelow: actionButton.bottomAnchor, multiplier: 1.5),
            barChart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barChart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barChart.heightAnchor.constraint(equalToConstant: minimumHeight - (safeAreaBottomHeight * 1.8))
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
        
        let chartData = BarChartData(dataSet: dataSet)
        
        barChart.data = chartData
        barChart.notifyDataSetChanged()
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
        
        UIView.animate(withDuration:0.5, animations: { () -> Void in
            if sender.transform == .identity {
                sender.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.999))
            } else {
                sender.transform = .identity
            }
        })
    }
    
    private func snapTo(height: CGFloat) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            let frame = self.view.frame
            self.view.frame = CGRectMake(0, frame.height - height, frame.width, frame.height)
        }
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
