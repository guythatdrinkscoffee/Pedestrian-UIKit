//
//  InfoRow.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit
import SwiftUI

class InfoRow: UIView {
    // MARK: - UI
    private lazy var horizontalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 5
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
        
        addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Methods
    public func addSections(_ infoSection: [InfoSection]){
        for section in infoSection {
            self.horizontalStackView.addArrangedSubview(section)
        }
    }
}

// MARK: - Preview
struct InfoRow_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let infoRow = InfoRow()
            
            infoRow.addSections([
                InfoSection(icon: UIImage(systemName: "figure.walk"), body: "\(4)", detail: "km"),
                InfoSection(icon: UIImage(systemName: "arrow.up.right"), body: "\(10)", detail: " "),
            ])
            
            return infoRow
        }
        .previewLayout(.sizeThatFits)
    }
}
