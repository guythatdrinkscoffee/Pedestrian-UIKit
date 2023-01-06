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
    let color: Color
    @ViewBuilder let destination: () -> Destination
    
    var defaultIconSize = CGSize(width: 30, height: 30)
    var iconRotation: Double = 0
    
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
        .foregroundColor(color)
    }
}

struct SettingsNavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNavigationRow(title: "General", icon: Image(systemName: "gear"), color: .gray) {
            Text("Hello World")
        }
        .previewLayout(.sizeThatFits)
    }
}
