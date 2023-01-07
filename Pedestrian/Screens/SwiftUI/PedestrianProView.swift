//
//  PedestrianProView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/7/23.
//

import SwiftUI

enum Feature: CaseIterable {
    case history
    case weather
    case support
    
    var title: String {
        switch self {
        case .history:
            return "Full step count history"
        case .weather:
            return "Access to Local Weather"
        case .support:
            return "Support indie development"
        }
    }
    
    var color: UIColor {
        switch self {
        case .history:
            return .systemPink
        case .weather:
            return .systemBlue
        case .support:
            return .systemRed
        }
    }
    
    
    var icon: any View {
        switch self {
        case .history:
            return SettingsIcon(
                size: .mediumIcon,
                icon: Image(systemName: "chart.bar.fill"),
                color: Color(uiColor: color),
                ratio: 1.8)
        case .weather:
            return TwoColorSettingsIcon(
                size: .mediumIcon,
                icon: Image(systemName: "cloud.sun.fill"),
                primary: .white,
                secondary: .yellow,
                background: .blue)
        case .support:
            return SettingsIcon(
                size: .mediumIcon,
                icon: Image(systemName: "heart.fill"),
                color: Color(uiColor: color),
                ratio: 1.8)
        }
    }
    
    var description: String {
        switch self {
        case .history:
            return "Access your entire step history beyond the last 7 days."
        case .weather:
            return "Keep track of your step count along with the weather."
        case .support:
            return "Pedestrian is a solo project, so your purchase directly supports the further development of the app."
        }
    }
    
    var caveats: String? {
        switch self {
        case .history:
            return "*This feature requires permission to Apple's Health Kit"
        case .weather:
            return "Provided by Apple Weather"
        default: return nil
        }
    }
}

struct PedestrianProView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                Text("Pedestrian Pro Includes: ")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(.secondary)
                ForEach(Feature.allCases, id: \.self) { feature in
                    FeatureRow(feature: feature)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.headline)
                    }
                    .tint(.secondary)
                }
            }
        }
    }
}

struct FeatureRow: View {
    var feature: Feature
    
    var body: some View {
        HStack(alignment: .top){
            AnyView(feature.icon)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(Color(uiColor: feature.color))
                
                Text(feature.description)
                    .font(.subheadline)
                
                if let caveat = feature.caveats {
                    Text(caveat)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(5)
    }
}

struct PedestrianProView_Previews: PreviewProvider {
    static var previews: some View {
        PedestrianProView()
    }
}

extension CGSize {
    static let mediumIcon = CGSize(width: 40, height: 40)
}
