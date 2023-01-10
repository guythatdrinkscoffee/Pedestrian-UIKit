//
//  SettingsView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/5/23.
//

import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.openURL) private var openURL
    
    @AppStorage(.dailyStepGoal) var dailyStepGoal = 5000
    @AppStorage(.preferMetricUnits) var preferMetricUnits = false
    @AppStorage(.allowNotifications) var allowNotifications = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    
                    Stepper(value: $dailyStepGoal, in: 100...100_000, step: 100) {
                        HStack {
                            SettingsIcon(size: CGSize(width: 30, height: 30), icon: Image(systemName: "figure.walk"), color: determineColorRange(dailyStepGoal))
                            
                            VStack(alignment: .leading){
                                Text("Daily Step Goal")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(dailyStepGoal, format: .number)
                                    .font(.system(.title, design: .monospaced, weight: .black))
                                    .foregroundColor(determineColorRange(dailyStepGoal))
                            }
                            .padding([.leading], 5)
                        }
                    }
                    .padding(3)
                    
                    
                    Toggle(isOn: $preferMetricUnits) {
                        HStack {
                            SettingsIcon(size: CGSize(width: 30, height: 30), icon: Image(systemName: "ruler.fill"), color: .purple, rotation: -45)
                            Text("Prefer Metric Units")
                                .font(.system(.subheadline, design: .default, weight: .semibold))
                                .padding([.leading], 10)
                        }
                    }
                } header: {
                    Text("General")
                }
                
                
                Section {
                    SettingsButton(title: "Twitter", icon: Image(systemName: "at"), color: .teal, ratio: 2) {
                        if let url = URL(string:  "https://twitter.com/idrankthecoffee") {
                            openURL(url)
                        }
                    }
                    .tint(.teal)
                    
                } header: {
                    Text("Feedback")
                }
        
                Section {
                    SettingsButton(title: "Privacy Policy", icon: Image(systemName: "hand.raised.fill"), color: .gray) {
                        if let url = URL(string:  "https://github.com/guythatdrinkscoffee") {
                            openURL(url)
                        }
                    }
                    .tint(.gray)
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                        impactGenerator.prepare()
                        impactGenerator.impactOccurred()
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
    
    func determineColorRange(_ value: Int) -> Color {
        switch value {
        case 0...5000 : return .red
        case 5000...10000 : return .orange
        case 10000...20000: return .green
        
        default:
            return .green
        }
    }
}


struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
