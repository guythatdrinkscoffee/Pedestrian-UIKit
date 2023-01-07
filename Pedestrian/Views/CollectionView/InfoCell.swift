//
//  InfoCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/4/23.
//

import UIKit

struct MetricsData {
    let icon: UIImage?
    let description: String?
    let value: Any?
}

struct MetricsInfo {
    let title: String
    let data: [MetricsData]
}

class InfoCell: UICollectionViewCell {
    // MARK: -  Properties
    static let resuseIdentifier = String(describing: InfoCell.self)
    
    public var data: MetricsData? {
        didSet {
            configure(with: data)
        }
    }
    
    // MARK: - UI
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.tintColor = .systemTeal
        return imageView
    }()
    
    private lazy var bodyLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var detailLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var labelsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, bodyLabel])
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var rootStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailLabel, labelsStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .center
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
        
        configureContentView()
        
        layoutContentViews()
    }
}

// MARK: - Configuration
extension InfoCell {
    private func configureContentView() {
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .secondarySystemBackground
    }
    
    public func configure(with data: MetricsData?) {
        guard let data = data else { return }
        
        if let number = data.value as? Int {
            bodyLabel.text = "\(number)"
        } else if let date = data.value as? Date {
            bodyLabel.text = date.formatted(date: .abbreviated, time: .omitted)
        } else if let string = data.value as? String {
            bodyLabel.text = string
        }
        
        iconImageView.image = data.icon
        detailLabel.text = data.description
    }
}

// MARK: - Layout
private extension InfoCell {
    private func layoutContentViews() {
        contentView.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            rootStackView.trailingAnchor.constraint(equalTo:contentView.trailingAnchor, constant: -8),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
