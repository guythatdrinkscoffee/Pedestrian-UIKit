//
//  ReusableHeaderView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/4/23.
//

import UIKit

class ReusableHeaderView: UICollectionReusableView {
    // MARK: - Properties
    static let reuseIdentifier = "ReusableHeaderView"
    
    // MARK: - UI
    private lazy var headerLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        return label
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
        
        addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1)
        ])
    }
}

// MARK: - Configuration
extension ReusableHeaderView {
    public func configure(with title: String?){
        headerLabel.text = title
    }
}
