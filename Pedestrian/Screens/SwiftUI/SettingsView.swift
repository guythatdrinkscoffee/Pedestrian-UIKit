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
    @State var presentPedestrianPro: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        SettingsButton(title: "Unlock Pedestrian Pro", icon: Image(systemName: "figure.walk"), color: .green, accessoryIcon: Image(systemName: "plus") ) {
                            presentPedestrianPro.toggle()
                        }
                        .tint(.green)
                    }
                    .padding([.top,.bottom], 5)
                }
                
                Section {
                    SettingsNavigationRow(title: "General", icon: Image(systemName: "gear"), color: .secondary) {
                        // Navigate to the general settings view
                        GeneralSettingsView()
                    }
                }
                
                Section {
                    SettingsNavigationRow(title: "Tip Jar", icon: Image(systemName: "app.gift.fill"), color: .purple) {
                        // Navigate to the tip jar view
                    }
                }
                
                Section {
                    SettingsButton(title: "Twitter", icon: Image(systemName: "at"), color: .teal, ratio: 2) {
                        if let url = URL(string:  "https://twitter.com/idrankthecoffee") {
                            openURL(url)
                        }
                    }
                    .tint(.teal)
                    
                    SettingsButton(title: "Email", icon: Image(systemName: "paperplane.fill"), color: .orange, ratio: 2) {
                        
                    }
                    .tint(.orange)
                    
                    SettingsButton(title: "Rate in App Store ", icon: Image(systemName: "star.fill"), color: .blue, ratio: 2) {
                        
                    }
                    .tint(.blue)
                } header: {
                    Text("Feedback")
                }
        
                Section {
                    SettingsNavigationRow(title: "Help", icon: Image(systemName: "questionmark.circle"), color: .pink) {
                        
                    }
                    
                    SettingsNavigationRow(title: "Privacy Policy", icon: Image(systemName: "hand.raised.fill")) {
                        
                    }
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
            .sheet(isPresented: $presentPedestrianPro) {
                PedestrianProView()
            }
        }
    }
}


struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
