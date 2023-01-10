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
