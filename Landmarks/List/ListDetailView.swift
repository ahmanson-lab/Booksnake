//
//  ListDetailView.swift
//  Landmarks
//
//  Created by Henry Huang on 2/27/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import SwiftUI

struct ListDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var collection: ItemCollection
    @State private var editMode = false
    
    var body: some View {
        List {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                        .frame(height: 10)
                    // Images
                    VStack(spacing: 0) {
                        let imageURLs = collection.compositeImageURLs
                        let topLeftImage = UIImage.loadThumbnail(at: imageURLs[safe: 0], forSize: .medium) ?? UIColor.lightGray.image()
                        let topRightImage = UIImage.loadThumbnail(at: imageURLs[safe: 1], forSize: .medium) ?? UIColor.lightGray.image()
                        let bottomLeftImage = UIImage.loadThumbnail(at: imageURLs[safe: 2], forSize: .medium) ?? UIColor.lightGray.image()
                        let bottomRightImage = UIImage.loadThumbnail(at: imageURLs[safe: 3], forSize: .medium) ?? UIColor.lightGray.image()

                        HStack(spacing: 0) {
                            Image(uiImage: topLeftImage)
                                .resizable()
                                .scaleEffect(1.1)   // some image has empty space, so we scale image to make it fill
                                .scaledToFill()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipped()
                                .animation(.none, value: topLeftImage)
                            Image(uiImage: topRightImage)
                                .resizable()
                                .scaleEffect(1.1)
                                .scaledToFill()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipped()
                                .animation(.none, value: topRightImage)
                        }
                        HStack(spacing: 0) {
                            Image(uiImage: bottomLeftImage)
                                .resizable()
                                .scaleEffect(1.1)
                                .scaledToFill()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipped()
                                .animation(.none, value: bottomLeftImage)
                            Image(uiImage: bottomRightImage)
                                .resizable()
                                .scaleEffect(1.1)
                                .scaledToFill()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipped()
                                .animation(.none, value: bottomRightImage)
                        }
                    }
                    .cornerRadius(5)

                    // Title
                    if editMode {
                        TextField("Untitled List", text: $collection.title)
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.bold))
                    } else {
                        Text("\(collection.title)")
                            .font(.title2)
                            .bold()
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }

                    Spacer()
                        .frame(height: 5)

                    // Subtitle
                    if editMode {
                        TextField("Subtitle", text: $collection.subtitle)
                            .multilineTextAlignment(.center)
                            .font(.title3.weight(.light))
                    } else {
                        if collection.subtitle != "" {
                            Text("\(collection.subtitle)")
                                .font(.title3.weight(.light))
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }
                    
                    // Author
                    if editMode {
                        HStack(spacing: 3) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                            TextField("List Creator", text: $collection.author)
                                .font(.footnote)
                        }
                        .fixedSize()
                        .frame(width: 200, height: nil, alignment: .center)
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                            Text("\(collection.author != "" ? collection.author : "Unknown")")
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()
                        .frame(height: 10)
                }
                Spacer()
            }

            if editMode {
                VStack {
                    Spacer()
                        .frame(height: 25)
                    TextField("Description", text: $collection.detail)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                        .frame(height: 25)
                }
            } else {
                if collection.detail != "" {
                    HStack {
                        Spacer()
                        Text("\(collection.detail)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(5)
                            .truncationMode(.tail)
                        Spacer()
                    }
                }
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
                .onDelete(perform: onDelete)
            } else {
                Text("Empty List")
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editMode.toggle()
                }, label: {
                    if editMode {
                        Text("Finish")
                    } else {
                        Text("Edit")
                    }
                })
            }
        }
    }
    
    private func onDelete(offsets: IndexSet) {
        guard let contentToDeassociate = collection.items?[offsets.first!] as? Manifest else {
            return
        }
        contentToDeassociate.removeFromCollections(collection)
        do {
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
}
