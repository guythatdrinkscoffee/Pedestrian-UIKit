//
//  SelectionCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class SelectionCell: UITableViewCell {
    // MARK: - Properties
    private var setting: SettingsSelection! = .none 
    
    // MARK: - UI
    private var titleLabel: UILabel!
    private var selectionLabel: UILabel!
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
}

// MARK: - Configuration
extension SelectionCell {
    private func configure(for setting: SettingsSelection) {
        isUserInteractionEnabled = true
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        accessoryType = .disclosureIndicator
        
        configureLabels(for: setting)
    }
    
    private func configureLabels(for setting: SettingsSelection) {
        self.titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .rounded(ofSize: 16, weight: .semibold)
        titleLabel.text = setting.title
        
        self.selectionLabel = UILabel()
        selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionLabel.font = .rounded(ofSize: 16, weight: .regular)
        selectionLabel.textColor = .systemGray
        selectionLabel.text = setting.selection.title
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectionLabel)
        
        let trailing: NSLayoutXAxisAnchor
        
        if let av = self.accessoryView {
            trailing = av.leadingAnchor
        } else {
            trailing = contentView.trailingAnchor
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionLabel.trailingAnchor.constraint(equalTo: trailing, constant: -16)
        ])
    }
}
// MARK: - SettingsCell
extension SelectionCell: SettingsCell {
    func set(setting: SettingsOption) {
        self.setting = setting as? SettingsSelection
        configure(for: self.setting)
    }
    
    func updateSetting(setting: SettingsOption) {
        if let setting = setting as? SettingsSelection {
            self.setting = setting
            selectionLabel.text = setting.selection.title
        }
    }
}
