//
//  SettingsButton.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/6/23.
//

import SwiftUI

struct SettingsButton: View  {
    let title: String
    let icon: Image
    let color: Color
    var accessoryIcon: Image = Image(systemName: "arrow.up.right")
    var defaultIconSize = CGSize(width: 30, height: 30)
    var ratio: Double = 1.5
    let action: (()->Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                SettingsIcon(size: defaultIconSize, icon: icon, color: color, ratio: ratio)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding([.leading], 10)
                
                Spacer()
                
                accessoryIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: defaultIconSize.width / 3, height: defaultIconSize.height / 3)
                    .fontWeight(.bold)
                    
            }
        }

    }
}


struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButton(title: "Email", icon: Image(systemName: "paperplane"), color: .red, accessoryIcon: Image(systemName: "arrow.up.right")) {
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
