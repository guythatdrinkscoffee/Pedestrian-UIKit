//
//  SettingsController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class SettingsController: UITableViewController {
    // MARK: - Properties
    private  var sections: [SettingsSection] = []
    
    public var updateSelection: ((IndexPath, SettingsOption) -> Void)?
    
    // MARK: - Life cycle
    init(sections: [SettingsSection], style: UITableView.Style = .insetGrouped){
        super.init(style: style)
        self.sections = sections
        configureReusableCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func updateSections(_ sections: [SettingsSection]) {
        self.sections = sections
    }
}

// MARK: - Configuration
extension SettingsController {
    private func configureReusableCells() {
        self.tableView.register(GroupCell.self, forCellReuseIdentifier: String(describing: GroupCell.self))
        self.tableView.register(ActionCell.self, forCellReuseIdentifier: String(describing: ActionCell.self))
        self.tableView.register(StepperCell.self, forCellReuseIdentifier: String(describing: StepperCell.self))
        self.tableView.register(SelectionCell.self, forCellReuseIdentifier: String(describing: SelectionCell.self))
        self.tableView.register(SwitchCell.self, forCellReuseIdentifier: String(describing: SwitchCell.self))
    }
    
    
    func updateForSelection(at indexPath: IndexPath, with selection: any Selection, for setting: SettingsOption){
        let cell = tableView.cellForRow(at: indexPath) as? SelectionCell
        cell?.updateSetting(setting: setting)
        sections[indexPath.section].settings[indexPath.row] = setting
    }
}

// MARK: - UITableViewDataSource
extension SettingsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let setting = sections[section].settings[row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: setting.withReuseIdentifier()) as? SettingsCell else {
            fatalError()
        }
        
        cell.set(setting: setting)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        let setting = sections[section].settings[row]
        
        return setting.highlight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        let setting = sections[section].settings[row]
        
        if let action = setting as? SettingsAction {
            action.action()
        } else if let options = setting.options {
            let vc = SettingsController(sections: options)
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.navigationItem.title = setting.title
            navigationController?.pushViewController(vc, animated: true)
        } else if var selection = setting as? SettingsSelection {
            let vc = SelectionController(selection: selection)
            vc.navigationItem.title = selection.title
            vc.updateSelecton = { newSelection in
                selection.updateSelection(with: newSelection)
                self.updateForSelection(at: indexPath, with: newSelection, for: selection)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        let setting = sections[section].settings[row]
        return setting.withRowHeight()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = sections[section].headerTitle
        
        guard title != nil else { return nil }
        
        let headerView = UIView(frame: .zero)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .systemGray
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.numberOfLines = 0
        
        headerView.addSubview(titleLabel)
        
        
        if let detailTitle = sections[section].detailTitle {
            let detailLabel = UILabel()
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.text = detailTitle
            detailLabel.textColor = .systemGray
            detailLabel.font = .preferredFont(forTextStyle: .footnote)
            detailLabel.numberOfLines = 0
            
            headerView.addSubview(detailLabel)
            
            NSLayoutConstraint.activate([
                headerView.trailingAnchor.constraint(equalToSystemSpacingAfter: detailLabel.trailingAnchor, multiplier: 2),
                detailLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])
        }
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: headerView.topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: headerView.leadingAnchor, multiplier: 2),
            headerView.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let title = sections[section].footerTitle
        
        guard title != nil else { return nil }
        
        let footerView = UIView(frame: .zero)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .systemGray
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.numberOfLines = 0
        
        footerView.addSubview(titleLabel)
      
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: footerView.topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: footerView.leadingAnchor, multiplier: 2),
            footerView.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2),
            titleLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let title = sections[section].footerTitle
        
        guard title != nil else { return 0}
        
        return 75
    }
}
