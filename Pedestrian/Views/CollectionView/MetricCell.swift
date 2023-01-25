//
//  MetricCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/25/23.
//

import UIKit

class MetricCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = String(describing: MetricsController.self)
    
    // MARK: - UI
    private lazy var bodyLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var detailLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var containerStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bodyLabel, detailLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - Configuration
extension MetricCell {
    public func set(title: String, value: String) {
        detailLabel.text = title
        bodyLabel.text = value
    }
}
