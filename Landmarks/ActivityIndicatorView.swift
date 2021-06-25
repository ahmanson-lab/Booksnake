//
//  ActivityIndicatorView.swift
//  Landmarks
//
//  Created by Christy Ye on 12/23/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    @Binding var text: String
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let temp = UIActivityIndicatorView(style: style)
        temp.color = UIColor.white
        return temp
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        
        let label = UILabel(frame: CGRect(x: -60, y: 0, width: 300, height: 100))
        label.text = text
        label.textColor = UIColor.white

        uiView.addSubview(label)
    }
}
