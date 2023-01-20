//
//  GroupCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class GroupCell: UITableViewCell {
    // MARK: - Properties
    private var setting: SettingsGroup! = .none {
        didSet {
            configure(for: setting)
        }
    }
    
    // MARK: - UI
    private var iconView: UIView!
    private var titleLabel: UILabel!
    
    // MARK: - Life cycle
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
}

// MARK: - Configuration
extension GroupCell {
    private func configure(for setting: SettingsGroup) {
        isUserInteractionEnabled = true
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        
        configureCell(for: setting)
        configureIconView(for: setting)
        configureLabels(for: setting)
    }
    private func configureCell(for setting: SettingsGroup) {
        if let _ = setting.options {
            accessoryType = .disclosureIndicator
        }
    }
    
    private func configureIconView(for setting: SettingsGroup){
        iconView = setting.icon.makeView()
        
        contentView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func configureLabels(for setting: SettingsGroup) {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .rounded(ofSize: 16, weight: .semibold)
        titleLabel.text = setting.title
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: iconView.trailingAnchor, multiplier: 2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - SettingsCell
extension GroupCell: SettingsCell {
    func set(setting: SettingsOption) {
        self.setting = setting as? SettingsGroup
    }
}
