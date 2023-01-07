//
//  SettingsNavigationRow.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/6/23.
//

import SwiftUI


struct SettingsNavigationRow<Destination: View>: View {
    let  title: String
    let icon: Image
 
    
    var color = Color(.gray)
    var defaultIconSize = CGSize(width: 30, height: 30)
    var iconRotation: Double = 0
    
    
    @ViewBuilder let destination: () -> Destination
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                SettingsIcon(size: defaultIconSize, icon: icon, color: color, rotation: iconRotation)
                Text(title)
                    .foregroundColor(.primary)
                    .font(.headline)
                    .padding([.leading], 10)
            }
        }
        .font(.headline)
    }
}

struct SettingsNavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNavigationRow(title: "General", icon: Image(systemName: "gear")) {
            Text("hello world")
        }
    }
}
