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
    
    // MARK: - UI
    private var settingsController: SettingsController!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuration
        configureViewController()
        configureNavigationBar()
        configureSettingsController()
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
    
    private func configureSettingsController() {
        let generalSection = SettingsSection(title: "General", settings: [
            SettingsGroup(icon: .general, title: "General", options: [])
        ])
        
        let aboutSection = SettingsSection(title: "About", settings: [
            SettingsAction(icon: .twitter, title: "Follow on Twitter", { self.openUrl(.twitterHandler) }),
            SettingsAction(icon: .feedback, title: "Send Feedback", { self.sendFeedback() })
        ])
        
        let privacySection = SettingsSection(title: "About", settings: [
            SettingsAction(icon: .privacy, title: "Privacy Policy", { self.openUrl(.privacyPolicy) }),
        ])
        
        settingsController = SettingsController(sections: [
            generalSection,
            aboutSection,
            privacySection
        ])
        
        add(settingsController, frame: view.frame)
    }
}

// MARK: - Methods
extension SettingsScreen: MFMailComposeViewControllerDelegate {
    private func openUrl(_ url: URL?) {
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
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

// MARK: - Preview
struct SettingsScreen_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let generalSection = SettingsSection(title: "General", settings: [
                SettingsGroup(icon: .general, title: "General", options: [])
            ])
            
            let aboutSection = SettingsSection(title: "About", settings: [
                SettingsAction(icon: .twitter, title: "Follow on Twitter", { }),
                SettingsAction(icon: .feedback, title: "Send Feedback", { })
            ])
            
            let privacySection = SettingsSection(title: "About", settings: [
                SettingsAction(icon: .privacy, title: "Privacy Policy", { }),
            ])
            
            let vc = SettingsController(sections: [
                generalSection,
                aboutSection,
                privacySection
            ])
            
            return vc
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
