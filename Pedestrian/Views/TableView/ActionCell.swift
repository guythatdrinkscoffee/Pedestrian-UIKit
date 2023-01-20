//
//  ActionCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class ActionCell: UITableViewCell {
    // MARK: - Properties
    private var setting: SettingsAction! = .none {
        didSet {
            configure(for: setting)
        }
    }
    
    // MARK: - UI
    private var iconView: UIView!
    private var titleLabel: UILabel!
    private var leading: NSLayoutXAxisAnchor!
    
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
extension ActionCell {
    private func configure(for setting: SettingsAction) {
        isUserInteractionEnabled = true
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        accessoryType  = .disclosureIndicator
        
        configureIconView(for: setting)
        configureLabels(for: setting)
    }
    
    private func configureIconView(for setting: SettingsAction) {
        if let iconView = setting.icon?.makeView() {
            self.iconView = iconView
            self.leading = iconView.trailingAnchor
            contentView.addSubview(iconView)
            
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
                iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            
        } else {
            self.leading = self.contentView.leadingAnchor
        }
    }
    
    private func configureLabels(for setting: SettingsAction) {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .rounded(ofSize: 16, weight: .semibold)
        titleLabel.text = setting.title
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leading, multiplier: 2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
// MARK: - SettingsCell
extension ActionCell: SettingsCell {
    func set(setting: SettingsOption) {
        self.setting = setting as? SettingsAction
    }
}
