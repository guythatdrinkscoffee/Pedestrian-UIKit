//
//  ReusableFooterView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/13/23.
//

import UIKit

class ReusableFooterView: UICollectionReusableView {
    // MARK: - Properties
    static let reuseIdentifier = "ReusableFooterView"
    
    // MARK: - UI
    private lazy var footerLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemGray
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
        
        addSubview(footerLabel)
        
        NSLayoutConstraint.activate([
            footerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            footerLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

// MARK: - Configuration
extension ReusableFooterView {
    public func configure(with title: String?){
        footerLabel.text = title
    }
}
