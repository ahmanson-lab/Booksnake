//
//  ListDetailView.swift
//  Landmarks
//
//  Created by Henry Huang on 2/27/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import SwiftUI

struct ListDetailView: View {
    let collection: ItemCollection
    let topLeftImage: UIImage
    let topRightImage: UIImage
    let bottomLeftImage: UIImage
    let bottomRightImage: UIImage
    
    var body: some View {
        List {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                        .frame(height: 10)
                    // Images
                    VStack(spacing: 0) {
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
                    // Title
                    Text("\(collection.title ?? "")")
                        .font(.title)
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                    Spacer()
                        .frame(height: 5)
                    // Subtitle
                    Text("\(collection.subtitle ?? "")")
                        .font(.title3)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    // Author
                    HStack(spacing: 3) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        Text("\(collection.author ?? "")")
                            .font(.footnote)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    Spacer()
                        .frame(height: 10)
                }
                Spacer()
            }

            HStack {
                Spacer()
                Text("\(collection.detail ?? "No Description")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(5)
                    .truncationMode(.tail)
                Spacer()
            }

            if let items = collection.items?.array as? [Manifest] {
                ForEach(items, id: \.self) { item in
                    let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()
                    NavigationLink(destination: LazyView(ContentView(imageURL: item.imageURL,
                                                                     width: (item.width),
                                                                     length: (item.length),
                                                                     labels: item.labels!,
                                                                     values: item.values! ))) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)

                        Text("\(item.itemLabel ?? "")")
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
            } else {
                Text("Empty List")
            }
        }
    }
}
