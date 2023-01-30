//
//  InfoSection.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit
import SwiftUI

class InfoSection: UIView {
    // MARK: - UI
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
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
        let stackView = UIStackView(arrangedSubviews: [iconImageView, bodyLabel, detailLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Life cycle
    convenience init(icon: UIImage?, body: String?, detail: String?) {
        self.init(frame: .zero)
        
        iconImageView.image = icon
        bodyLabel.text = body
        detailLabel.text = detail
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    public func updateBodyLabel(_ string: String?) {
        bodyLabel.text = string
    }
}

// MARK: - Preview
struct InfoSection_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let infoSection = InfoSection(icon: UIImage(systemName: "arrow.up.right"), body: "\(4)", detail: "km")
            return infoSection
        }
        .frame(height: 60)
    }
}
