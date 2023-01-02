//
//  UIViewPreview.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let uiView: View
    
    init(_ builder: @escaping () -> View) {
        uiView = builder()
    }
    
    func makeUIView(context: Context) -> some UIView {
        uiView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
#endif
