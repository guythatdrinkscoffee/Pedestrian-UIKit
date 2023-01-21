//
//  SelectionController.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/20/23.
//

import UIKit

class SelectionController: UITableViewController {
    private var settingsSelection: SettingsSelection!
    private var currentSelectedIndexPath: IndexPath!
    public var updateSelecton: ((any Selection)->Void)?
    
    init(selection: SettingsSelection, style: UITableView.Style = .insetGrouped){
        super.init(style: style)
        self.settingsSelection = selection
        self.tableView.register(SelectionCaseCell.self, forCellReuseIdentifier: "SelectionCaseCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settingsSelection.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCaseCell", for: indexPath) as? SelectionCaseCell else {
            fatalError()
        }
        
        let selection = settingsSelection.data[indexPath.row]
        
        cell.configure(for: selection)
        
        if settingsSelection.selection.value == selection.value {
            cell.accessoryType = .checkmark
            currentSelectedIndexPath = indexPath
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard currentSelectedIndexPath != indexPath else { return }
        
        let currentlySelectedCell = tableView.cellForRow(at: currentSelectedIndexPath)
        currentlySelectedCell?.accessoryType = .none
        
        let newlySelectedCell = tableView.cellForRow(at: indexPath)
        newlySelectedCell?.accessoryType = .checkmark
        
        currentSelectedIndexPath = indexPath
        
        
        let newSelection = settingsSelection.data[indexPath.row]
        
        UserDefaults.standard.set(newSelection.value, forKey: settingsSelection.key)
        
        updateSelecton?(newSelection)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
