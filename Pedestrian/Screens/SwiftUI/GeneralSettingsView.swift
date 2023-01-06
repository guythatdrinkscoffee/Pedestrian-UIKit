//
//  GeneralSettingsView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/6/23.
//

import SwiftUI


struct GeneralSettingsView: View {
    @AppStorage(.dailyStepGoal) var dailyStepGoal = 10_000

    
    let defaultIconSize = CGSize(width: 30, height: 30)
    
    var body: some View {
        List {
            Section {
                Stepper(value: $dailyStepGoal, in: 100...100_000, step: 100) {
                    HStack {
                        Text(dailyStepGoal, format: .number)
                            .font(.system(.title, design: .monospaced, weight: .black))
                            .padding([.leading], 5)
                    }
                }
                .padding(3)
            } header: {
                Text("Daily Step Goal")
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
