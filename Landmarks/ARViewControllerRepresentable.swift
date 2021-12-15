//
//  ARQuickLook.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/22/20.
//  Original code by Jim Dovey
//

import SwiftUI
import QuickLook
import ARKit

struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    var imageURL: URL?
    var width: CGFloat?
    var length: CGFloat?
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let image = UIImage(contentsOfFile: imageURL?.path ?? "") ?? UIImage()
        let picker = ARView()
        picker.texture_image = image
        picker.width = width
        picker.length = length
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //nothing
    }
    
}
