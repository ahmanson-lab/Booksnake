//
//  ContentView.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/21/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var showingPreview = false
    @State private var showText = false
    
    let image: UIImage?
    var width: CGFloat
    var length: CGFloat
    var labels: [String]
    var values: [String]

    var body: some View {
        RectangularImage(image: image!)
            .padding(EdgeInsets(top: -20, leading: 20, bottom: 20, trailing: 20))
        
        NavigationLink(
            destination: ARViewControllerRepresentable(image: image!, width:width, length: length)
                .navigationBarTitle("")
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center),
            isActive: $showingPreview){
                ZStack(){
                    Color.init(.systemBlue)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50, alignment: .center)
                        .cornerRadius(10)
                    Text("View in AR")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        }
           
        VStack (alignment: .leading, spacing:10) {
            List{
                ForEach(0..<(labels.count)){ item in
                    VStack (alignment: .leading) {
                            Text("\(labels[item])")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                            Text("\(values[item])")
                                .font(.headline)
                        }
                    }
                }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
    }
}

