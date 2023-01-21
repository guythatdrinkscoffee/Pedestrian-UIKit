//
//  SelectionCaseCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class SelectionCaseCell: UITableViewCell {
    // MARK: - Property
    private var selection: (any Selection)! = .none {
        didSet {
            titleLabel.text = selection.title
        }
    }
    
    // MARK: - UI
    private var titleLabel: UILabel!
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "kek"
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

// MARK: - Configuration
extension SelectionCaseCell {
    public func configure(for selection: any Selection) {
        self.selection = selection
    }
}
