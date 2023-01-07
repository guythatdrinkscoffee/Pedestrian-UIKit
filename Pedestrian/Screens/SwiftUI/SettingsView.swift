//
//  SettingsView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/5/23.
//

import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @State var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    SettingsNavigationRow(title: "General", icon: Image(systemName: "gear"), color: .secondary) {
                        GeneralSettingsView()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        feedbackGenerator?.impactOccurred()
                        dismiss()
                    } label: {
                        Text("Done")
                    }

                }
            }
            .onAppear {
                feedbackGenerator = UIImpactFeedbackGenerator(style: .medium )
            }
            .onDisappear {
                feedbackGenerator = nil
            }
        }
    }
}


struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
