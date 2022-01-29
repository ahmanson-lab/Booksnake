//
//  ActivityIndicatorView.swift
//  Landmarks
//
//  Created by Christy Ye on 12/23/20.
//  Copyright © 2020 University of Southern California. All rights reserved.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    @Binding var text: String
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let temp = UIActivityIndicatorView(style: style)
        temp.color = .white
        return temp
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        
        let label = UILabel(frame: .zero)
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.minimumScaleFactor = 0.3

        uiView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        label.topAnchor.constraint(equalTo: uiView.bottomAnchor, constant: 25.0).isActive = true
        label.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
    }
}
