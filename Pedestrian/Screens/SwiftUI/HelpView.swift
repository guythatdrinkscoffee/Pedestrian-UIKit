//
//  HelpView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/9/23.
//

import SwiftUI

fileprivate enum FAQ: CaseIterable {
    case stepCollection
    
    
    var title: String {
        switch self {
        case .stepCollection:
            return "How is my step data collected?"
        }
    }
    
    var description: String {
        switch self {
        case .stepCollection:
            return """
                Your step data can be collected in two ways. The first is with the device's built-in pedometer which only returns the step count from that device at a much more frequent rate. The second and only applicable with Pedestrian Pro is from Apple's Health Kit which returns an aggregate step count of all connected devices.
                """
        }
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section {
                ForEach(FAQ.allCases, id:\.self) { faq in
                    DisclosureGroup {
                        Text(faq.description)
                            .font(.subheadline)
                            
                    } label: {
                        Text(faq.title)
                            .font(.headline)
                    }


                }
            } header: {
                Text("FAQ")
            }

        }
        .navigationTitle("Support")
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
