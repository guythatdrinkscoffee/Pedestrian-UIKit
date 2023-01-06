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
    let accessoryIcon: Image
    var defaultIconSize = CGSize(width: 30, height: 30)
    let action: (()->Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                SettingsIcon(size: defaultIconSize, icon: icon, color: color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding([.leading], 10)
                
                Spacer()
                
                accessoryIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: defaultIconSize.width / 2.5, height: defaultIconSize.height / 2.5)
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
