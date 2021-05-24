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
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        
        let label = UILabel(frame: CGRect(x: -50, y: 0, width: 300, height: 100))
        label.text = "Adding to Booksnake"
        label.textColor = UIColor.gray
        //label.textAlignment = .center
        
        //UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //let rectangle = UIImage(named: "white")
        //rectangle?.withTintColor(UIColor.init(white: 0.5, alpha: 0.4))
        //let bk = UIView(frame: CGRect(x: -100, y: -100, width: 200, height: 200))//UIImageView(image: rectangle)
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = CGRect(x: -50, y: -50, width: 200, height: 200)
        
        
      //  bk.backgroundColor = UIColor.init(white: 0.6, alpha: 0.4)
        
        //bk.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
      //  uiView.addSubview(blurEffectView)
        uiView.addSubview(label)
    }
}
