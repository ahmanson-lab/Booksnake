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
    
    @State var image: UIImage = UIImage()
	//@State var image_url: String
	@State var width: CGFloat = 5
    var length: CGFloat
    var labels: [String]
    var values: [String]

    var body: some View {
		List {
			HStack{
				Spacer()
			RectangularImage(image: image)
				.frame(height: UIScreen.main.bounds.height / 2, alignment: .center)
				Spacer()
			}
			
			NavigationLink(
				destination: RealityViewRepresentable(image: image, width:width, length: length) //, image_url: image_url)
					.navigationBarTitle("")
					.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center),
				isActive: $showingPreview){
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
		.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
    }
}

