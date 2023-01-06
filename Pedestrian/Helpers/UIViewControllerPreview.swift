//
//  UIViewControllerPreview.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/5/23.
//

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let vc: ViewController
    
    init(_ builder: @escaping () -> ViewController){
        vc = builder()
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
#endif
