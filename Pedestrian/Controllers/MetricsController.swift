//
//  MetricsController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/25/23.
//

import UIKit
import CoreMotion

struct MetricsSection {
    let title: String
    let metrics: [Metrics]
    let height: CGFloat
    
    init(title: String, metrics: [Metrics], height: CGFloat = 65){
        self.title = title
        self.metrics = metrics
        self.height = height
    }
}

struct Metrics {
    let title: String
    let value: String
    let icon: UIImage?
    
    init(title: String, value: String, icon: UIImage? = nil){
        self.title = title
        self.value = value
        self.icon = icon
    }
}

enum MetricsType {
    case lastSixDays
    case selection(Date)

    var name: String {
        switch self {
        case .lastSixDays: return "Last six days"
        case .selection(let date): return date.formatted(.dateTime.weekday(.wide).month().day())
        }
    }
}

class MetricsController: UIViewController {
    // MARK: - Properties
    private var data: [CMPedometerData] = []
    private var metrics: [MetricsSection] = []
    private var settingsManager: SettingsManager?

    // MARK: - UI
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 30)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MetricCell.self, forCellWithReuseIdentifier: MetricCell.reuseIdentifier)
        collectionView.register(ReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReusableHeaderView.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - Life cycle
    init(data: [CMPedometerData] = [], settingsManager: SettingsManager? = nil){
        super.init(nibName: nil, bundle: nil)
        self.data = data
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
}

// MARK: - Config
extension MetricsController {
    private func configureViewController(){
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
    }
}

// MARK: - Layout
extension MetricsController {
    private func layoutViews() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            collectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: 1),
        ])
    }
}

// MARK: - Public Methods
extension MetricsController {
    public func setData(_ data: [CMPedometerData], for type: MetricsType = .lastSixDays) {
        self.aggregateData(for: data, with: type)
    }
    
    public func setMetrics(_ metrics: [MetricsSection]) {
        self.metrics = metrics
        self.collectionView.reloadData()
    }
}

// MARK: - Private Methods
extension MetricsController {
    private func aggregateData(for data: [CMPedometerData], with type: MetricsType) {
        // Total Steps
        let totalSteps = data.reduce(0, {$0 + $1.numberOfSteps.intValue}).formatted(.number)
        
        // Total Distance Calculation and formatting
        let totalDistance = data.reduce(0.0, {$0 + ($1.distance?.doubleValue ?? 0.0)})
        let distanceUnit = self.settingsManager?.distanceUnitsPublisher.value ?? .miles
        let unitLength : UnitLength  = distanceUnit == .miles ? .miles : .kilometers
        let totalDistanceInSpecifiedUnit = Measurement<UnitLength>(value: totalDistance, unit: .meters).converted(to: unitLength)
        let totalDistanceValue = totalDistanceInSpecifiedUnit.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(1))))
        
        // Total floors ascended
        let totalFloorsAscended = data.reduce(0, {$0 + ($1.floorsAscended?.intValue ?? 0)}).formatted(.number)
        
        // Total floors descended
        let totalFloorsDescended = data.reduce(0, {$0 + ($1.floorsDescended?.intValue ?? 0)}).formatted(.number)
        
        self.metrics = [
            .init(title: type.name, metrics: [
                .init(title: "Step Count", value: totalSteps),
                .init(title: "Distance Traveled", value: totalDistanceValue),
                .init(title: "Floors Ascended", value: totalFloorsAscended),
                .init(title: "Floors Descended", value: totalFloorsDescended)
            ])
        ]
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView
extension MetricsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        
        return CGSize(width: size, height: metrics[indexPath.section].height)
    }
}


// MARK: - UICollectionViewDataSource
extension MetricsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCell.reuseIdentifier, for: indexPath) as? MetricCell else {
            fatalError("Failed to dequeue a reusable cell")
        }
        
        let metric = metrics[indexPath.section].metrics[indexPath.row]
        cell.set(metric: metric)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return metrics.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metrics[section].metrics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReusableHeaderView.reuseIdentifier, for: indexPath)
            
            guard let titledHeader = header as? ReusableHeaderView else {
                return header
            }
            
            let section = indexPath.section
            let sectionTitle = metrics[section].title
            
            titledHeader.configure(with: sectionTitle)
            
            return titledHeader
        default:
            fatalError("reusable header of \(kind) is not yet supported")
        }
        
    }
}
