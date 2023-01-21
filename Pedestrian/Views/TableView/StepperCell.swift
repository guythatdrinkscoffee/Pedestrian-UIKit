//
//  StepperCell.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class StepperCell: UITableViewCell {
    // MARK: - Properties
    private var setting: SettingsStepper! = .none {
        didSet{
            configure(for: setting)
        }
    }
    
    private var leading: NSLayoutXAxisAnchor!
    private var iconView: UIView!
    private var detailLabel: UILabel!
    private var valueLabel: UILabel!
    private var stepper: UIStepper!
    
    // MARK: -  Life Cycle
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
extension StepperCell {
    private func configure(for setting: SettingsStepper){
        isUserInteractionEnabled = true
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        
        configureIconView(for: setting)
        configureStepper(for: setting)
        configureLabels(for: setting)
    }
    
    private func configureIconView(for setting: SettingsStepper){
        if let iconView = setting.icon?.makeView() {
            self.iconView = iconView
            self.leading = iconView.trailingAnchor
            contentView.addSubview(iconView)
            
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            
        } else {
            self.leading = contentView.leadingAnchor
        }
    }
    
    private func configureLabels(for setting: SettingsStepper) {

        self.detailLabel = UILabel()
        detailLabel.font = .rounded(ofSize: 16, weight: .semibold)
        detailLabel.text = setting.title
        
        let value = Int(getValue())
        self.valueLabel = UILabel()
        valueLabel.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        valueLabel.minimumScaleFactor = 0.75
        valueLabel.text = value.formatted(.number)
        valueLabel.textColor = getColorForValue(value: value)
        let stackView = UIStackView(arrangedSubviews: [detailLabel, valueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func configureStepper(for setting: SettingsStepper) {
        self.stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.minimumValue = setting.minimum
        stepper.maximumValue = setting.maximum
        stepper.stepValue = setting.stepBy
        stepper.value = getValue()
        stepper.addTarget(self, action: #selector(handleStepper(_:)), for: .valueChanged)
        
        contentView.addSubview(stepper)
        
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalToSystemSpacingAfter: stepper.trailingAnchor, multiplier: 2),
            stepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func getValue() -> Double {
        return UserDefaults.standard.double(forKey: setting.key)
    }
    
    private func getColorForValue(value: Int) -> UIColor {
        switch value {
        case 100..<5_000: return .systemRed
        case 5_000..<10_000: return .systemOrange
        default: return .systemGreen
        }
    }
    
    @objc
    private func handleStepper(_ sender: UIStepper) {
        let value = Int(sender.value)
        valueLabel.text = value.formatted(.number)
        valueLabel.textColor = getColorForValue(value: value)
        
        UserDefaults.standard.set(sender.value, forKey: setting.key)
    }
}

// MARK: - SettingsCell
extension StepperCell: SettingsCell {
    func set(setting: SettingsOption) {
        self.setting = setting as? SettingsStepper
    }
}
