//
//  SwitchCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class SwitchCell: UITableViewCell {
    // MARK: - Properties
    private var setting: SettingsSwitch! = .none {
        didSet {
            configure(for: setting)
        }
    }
    
    // MARK: - UI
    private var titleLabel: UILabel!
    private var uiSwitch: UISwitch!
        
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
extension SwitchCell {
    private func configure(for setting: SettingsSwitch) {
        isUserInteractionEnabled = true

        configureLabels(for: setting)
        configureSwitch(for: setting)
    }
    
    private func configureLabels(for setting: SettingsSwitch){
        self.titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .rounded(ofSize: 16, weight: .semibold)
        titleLabel.text = setting.title
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func configureSwitch(for setting: SettingsSwitch) {
        self.uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.isOn = setting.isOn
        uiSwitch.addTarget(self, action: #selector(handleSwitch(_:)), for: .valueChanged)
        contentView.addSubview(uiSwitch)
        
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalToSystemSpacingAfter: uiSwitch.trailingAnchor, multiplier: 2),
            uiSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func getValue() -> Bool {
        return UserDefaults.standard.bool(forKey: setting.key)
    }
    
    @objc
    private func handleSwitch(_ sender: UISwitch) {
        uiSwitch.isOn = sender.isOn
        
        UserDefaults.standard.set(sender.isOn, forKey: setting.key)
    }
}

// MARK: - SettingsCell
extension SwitchCell: SettingsCell {
    func set(setting: SettingsOption) {
        self.setting = setting as?  SettingsSwitch
    }
}
