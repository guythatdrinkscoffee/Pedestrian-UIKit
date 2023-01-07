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
    var ratio: Double = 1.5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: size.width, height: size.height)
            .foregroundColor(color)
            .overlay {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width / ratio, height: size.height / ratio)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .rotationEffect(Angle(degrees: rotation))
            }
    }
}

struct TwoColorSettingsIcon: View {
    let size: CGSize
    let icon: Image
    let primary: Color
    let secondary: Color
    let background: Color
    var rotation: Double = 0
    var ratio: Double = 1.5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: size.width, height: size.height)
            .foregroundColor(background)
            .overlay {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width / ratio, height: size.height / ratio)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(primary, secondary)
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
