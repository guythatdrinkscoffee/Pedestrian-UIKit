//
//  SettingsIcon.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/6/23.
//

import SwiftUI


struct SettingsIcon: View {
    let size: CGSize
    let icon: Image
    let color: Color
    var rotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: size.width, height: size.height)
            .foregroundColor(color)
            .overlay {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width / 1.5, height: size.height / 1.5)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .rotationEffect(Angle(degrees: rotation))
            }
    }
}


struct SettingsIcon_Previews: PreviewProvider {
    static var previews: some View {
        SettingsIcon(size: CGSize(width: 30, height: 0), icon: Image(systemName: "figure.walk"), color: .green)
    }
}
