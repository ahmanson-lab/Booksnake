//
//  CreateListView.swift
//  Landmarks
//
//  Created by Christy Ye on 2/10/22.
//  Copyright © 2022 Sean Fraga. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct NewListView: View{
	@Environment(\.presentationMode) var presentation
    @State private var collectionTitle: String = ""
    @State private var collectionSubtitle: String = ""
    @State private var collectionCreator: String = ""
    @State private var collectionDescription: String = ""

    
	var body: some View{
        NavigationView {
            List {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                            .frame(height: 10)
                        // Images
                        VStack(spacing: 0) {
                            let topLeftImage = UIColor.gray.image()
                            let topRightImage =  UIColor.gray.image()
                            let bottomLeftImage = UIColor.gray.image()
                            let bottomRightImage = UIColor.gray.image()

                            HStack(spacing: 0) {
                                Image(uiImage: topLeftImage)
                                    .resizable()
                                    .scaleEffect(1.1)   // some image has empty space, so we scale image to make it fill
                                    .scaledToFill()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipped()
                                Image(uiImage: topRightImage)
                                    .resizable()
                                    .scaleEffect(1.1)
                                    .scaledToFill()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipped()
                            }
                            HStack(spacing: 0) {
                                Image(uiImage: bottomLeftImage)
                                    .resizable()
                                    .scaleEffect(1.1)
                                    .scaledToFill()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipped()
                                Image(uiImage: bottomRightImage)
                                    .resizable()
                                    .scaleEffect(1.1)
                                    .scaledToFill()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipped()
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Title
                        TextField("Untitled List", text: $collectionTitle)
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.bold))

                        // Subtitle
                        TextField("Subtitle", text: $collectionSubtitle)
                            .multilineTextAlignment(.center)
                            .font(.title3.weight(.light))
                        // Author
                        HStack(spacing: 3) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                            TextField("List Creator", text: $collectionCreator)
                                .font(.footnote)
                        }
                        .fixedSize()
                        .frame(width: 200, height: nil, alignment: .center)

                        Spacer()
                            .frame(height: 5)
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                        .frame(height: 25)
                    TextField("Description", text: $collectionDescription)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                        .frame(height: 25)
                }

                Text("Empty List")
            }
            .navigationTitle(Text("New List"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button("Cancel"){
                        print("back")
                        self.presentation.wrappedValue.dismiss()
                    }.foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done"){ }
                }
            }
		}
	}
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
