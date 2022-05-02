//
//  ContentView.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/21/20.
//  Copyright © 2020 University of Southern California. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var showingPreview = false
    @State private var showText = false
    var imageURL: URL?
	
	var width: Float = 1.0
	var length: Float = 1.0
	
    var labels: [String]
    var values: [String]

	@Binding var isTabShown: Bool
	
    var body: some View {
        List {
            VStack {
                Spacer()
                    .frame(height: 10)
                HStack{
                    Spacer()
                    let image = UIImage.loadThumbnail(at: imageURL, forSize: .medium) ?? UIImage()
                    RectangularImage(image: image)
                        .frame(height: UIScreen.main.bounds.height / 2, alignment: .center)
                    Spacer()
                }
            }

            NavigationLink(
                destination: LazyView(RealityViewRepresentable(width:width, length: length, image_url: imageURL, title: values[0]))
                    .navigationBarTitle("")
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center),
                isActive: $showingPreview) {
                    ZStack(){
                        Color.init(.systemBlue)
                            .cornerRadius(10)
                        Text("View in AR")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium, design: .default))
                    }
                    .frame(height: 50.0)
                    .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                }
            ForEach(0..<labels.count, id: \.self){ item in
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
        .navigationBarTitle("", displayMode: .inline)
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
    }
}
