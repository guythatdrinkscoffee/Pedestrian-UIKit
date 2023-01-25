//
//  SettingsScreen.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/14/23.
//

import UIKit
import SwiftUI
import MessageUI

class SettingsScreen: UIViewController {
    // MARK: - Properties
    private var feedbackImpactGenerator: UIImpactFeedbackGenerator?
    private var sections: [SettingsSection] = [ ]
    private var settingsManager: SettingsManager?
    // MARK: - UI
    private var settingsController: SettingsController!
    
    // MARK: - Life cycle
    init(_ settingsManager: SettingsManager? = nil){
        super.init(nibName: nil, bundle: nil)
        self.settingsManager = settingsManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuration
        configureViewController()
        configureNavigationBar()
        configureSettingsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if settingsController != nil {
            settingsController.updateSections(configureSections())
        }
    }
}

// MARK: - Configuration
private extension SettingsScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Settings"
    }
    
    private func configureNavigationBar() {
        feedbackImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        let rightBarButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction(){ _ in
            self.feedbackImpactGenerator?.prepare()
            
            self.feedbackImpactGenerator?.impactOccurred()
            
            self.dismiss(animated: true) {
                self.feedbackImpactGenerator = nil
            }
        })
        
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureGeneralGroup() -> SettingsSection {
        let steps = SettingsStepper(title: "Daily Step Goal", minimum: 100, maximum: 100_000, key: .dailyStepGoal)
        
        let distance = SettingsSelection(title: "Distance Units", selection: DistanceUnits(rawValue: UserDefaults.standard.integer(forKey: .distanceUnits)) ?? .miles, data: DistanceUnits.allCases, key: .distanceUnits)
        
        let generalGroup = SettingsGroup(icon: .general, title: "General", options: [
            .init(title: "STEPS", settings: [steps]),
            .init(title: "DISPLAY", settings: [distance])
        ])
        
        return .init(settings: [ generalGroup ])
    }
    
    private func configureContactGroup() -> SettingsSection {
        return .init(settings: [
            SettingsAction(icon: .twitter, title: "Follow on Twitter", options: [], {
                self.openUrl(.twitterHandler)
            }),
            
            SettingsAction(icon: .feedback, title: "Send Feedback", options: [], {
                self.sendFeedback()
            })
        ])
    }
    
    private func configureExportGroup() -> SettingsSection {
        return .init(settings: [
            SettingsGroup(icon: .export, title: "Export Step Data", options: [
                SettingsSection(title: "ALL DATA",settings: [
                    SettingsAction(title: "Export CSV", {
                        self.exportAllStepData()
                    })
                ], footerTitle: "Reported step data is collected from the device's onboard hardware and may differ from other step count reportings.", detailTitle: "Since \(PersistenceManager.shared.getFirstEntryDate().formatted(.dateTime.day().month().year()))")
            ])
        ])
    }
    
    
    private func configurePrivacyGroup() -> SettingsSection {
        return .init(settings: [
            SettingsGroup(icon: .analytics, title: "Crash Reporting & Analytics", options: [
                SettingsSection(settings: [
                    SettingsSwitch(title: "Opt-Out" , isOn: UserDefaults.standard.bool(forKey: .analyticsCollectionAllowed), key: .analyticsCollectionAllowed)
                ], footerTitle: "Crash Reporting & Analytics collection is used to fix any potential bugs.")
            ]),
            
            SettingsAction(icon: .privacy, title: "Privacy Policy", options: [], {
                self.openUrl(.privacyPolicy)
            })
        ])
    }
    
    private func configureSections() -> [SettingsSection] {
        return [
            configureGeneralGroup(),
            configureExportGroup(),
            configureContactGroup(),
            configurePrivacyGroup()
        ]
    }
    
    private func configureSettingsController() {
        self.sections = configureSections()
        settingsController = SettingsController(sections: sections)
        add(settingsController, frame: view.frame)
    }
    
}

// MARK: - Methods
extension SettingsScreen {
    private func openUrl(_ url: URL?) {
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func exportAllStepData() {
        let stepData = PersistenceManager.shared.getAll()
        let csvMaker = CSVMaker(data: stepData, distanceUnits: settingsManager?.distanceUnitsPublisher.value)
        
        if let csvURL = csvMaker.makeCSV(){
            let actionSheet = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
            self.present(actionSheet, animated: true)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsScreen: MFMailComposeViewControllerDelegate {
    private func sendFeedback() {
        let iosVerion = ProcessInfo.processInfo.operatingSystemVersionString
        let appVersion = Bundle.main.releaseVersionNumber ?? "1.0"
        let buildNumber = Bundle.main.buildVersionNumber ?? "1"
        
        if MFMailComposeViewController.canSendMail() {
            let htmlBody = """
            <ul>
                <li>iOS: \(iosVerion) </li>
                <li>Version: \(appVersion) (\(buildNumber)) </li>
            </ul>
            """
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Pedestrian Feedback")
            mail.setToRecipients(["jmanueldev@gmail.com"])
            mail.setMessageBody(htmlBody, isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
            print("Cannot send email")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Bundle
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
