//
//  GeneralSettingsView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/6/23.
//

import SwiftUI


struct GeneralSettingsView: View {
    @AppStorage(.dailyStepGoal) var dailyStepGoal = 5000
    @AppStorage(.preferMetricUnits) var preferMetricUnits = false
    
    var body: some View {
        List {
            Section {
                Stepper(value: $dailyStepGoal, in: 100...100_000, step: 100) {
                    HStack {
                        Text(dailyStepGoal, format: .number)
                            .font(.system(.title, design: .monospaced, weight: .black))
                            .padding([.leading], 10)
                            .foregroundColor(determineColorRange(dailyStepGoal))
                    }
                }
                .padding(3)
            } header: {
                Text("Daily Step Goal")
            }
            
            Section {
                Toggle(isOn: $preferMetricUnits) {
                    Text("Prefer Metric Units")
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .padding([.leading], 10)
                }
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
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


struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
