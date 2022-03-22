//
//  MainListsView.swift
//  Landmarks
//
//  Created by Christy Ye on 2/10/22.
//  Copyright © 2022 Sean Fraga. All rights reserved.
//

import SwiftUI
import UIKit

struct RootListView : View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: ItemCollection.sortedFetchRequest()) var itemCollections: FetchedResults<ItemCollection>
	var delegate: AssetRowProtocol?
	
	@State private var showNewListView = false
	
	var body: some View {
		VStack{
            HStack {
                Button(action: {
                    self.showNewListView = true
                }, label: {
                    Image(systemName: "text.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("New List")
                })
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(18)
                .sheet(isPresented: $showNewListView){
                    NewListView()
                        .interactiveDismissDisabled(true)
                }
                
                Button(action: {
                    // TODO: Implement Import feature
                }, label: {
                    Image(systemName: "link.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("Import List")
                })
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(18)
            }

            List {
                ForEach(itemCollections, id: \.self) { collection in
                    let imageURLs = collection.compositeImageURLs
                    let topLeftImage = UIImage.loadThumbnail(at: imageURLs[safe: 0], forSize: .small) ?? UIColor.lightGray.image()
                    let topRightImage = UIImage.loadThumbnail(at: imageURLs[safe: 1], forSize: .small) ?? UIColor.lightGray.image()
                    let bottomLeftImage = UIImage.loadThumbnail(at: imageURLs[safe: 2], forSize: .small) ?? UIColor.lightGray.image()
                    let bottomRightImage = UIImage.loadThumbnail(at: imageURLs[safe: 3], forSize: .small) ?? UIColor.lightGray.image()

                    NavigationLink(destination: LazyView(ListDetailView(collection: collection))) {
                        HStack(spacing: 14) {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Image(uiImage: topLeftImage)
                                        .resizable()
                                        .scaleEffect(1.1)   // some image has empty space, so we scale image to make it fill
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                        .animation(.none, value: topLeftImage)
                                    Image(uiImage: topRightImage)
                                        .resizable()
                                        .scaleEffect(1.1)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                        .animation(.none, value: topRightImage)
                                }
                                HStack(spacing: 0) {
                                    Image(uiImage: bottomLeftImage)
                                        .resizable()
                                        .scaleEffect(1.1)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                        .animation(.none, value: bottomLeftImage)
                                    Image(uiImage: bottomRightImage)
                                        .resizable()
                                        .scaleEffect(1.1)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                        .animation(.none, value: bottomRightImage)
                                }
                            }
                            .cornerRadius(5)

                            VStack(alignment: .leading) {
                                Spacer()
                                    .frame(height: 5)
                                Text("\(collection.title)")
                                    .font(.headline)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                Spacer()
                                    .frame(height: 3)
                                Text("\(collection.subtitle)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(3)
                                    .truncationMode(.tail)
                                Spacer()
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
                                Spacer()
                                    .frame(height: 5)
                            }
                        }
                    }
                }
                .onDelete(perform: onDelete)
            }
		}
	}
    
    private func onDelete(offsets: IndexSet) {
        guard let contentToDelete = itemCollections[safe: offsets.first!] else {
            return
        }
        
        self.managedObjectContext.delete(contentToDelete)
        do {
            try self.managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
}
