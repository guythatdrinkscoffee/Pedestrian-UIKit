//
//  SettingsView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/5/23.
//

import SwiftUI

enum Settings {
    
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
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
                        dismiss()
                    } label: {
                        Text("Done")
                    }

                }
            }
        }
    }
}


struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
