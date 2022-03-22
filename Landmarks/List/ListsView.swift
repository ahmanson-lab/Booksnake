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
    @FetchRequest(fetchRequest: ItemCollection.sortedFetchRequest()) var itemCollection: FetchedResults<ItemCollection>
	var delegate: AssetRowProtocol?
	
	@State var modalDisplayed = false
	
	var body: some View {
		VStack{
            HStack {
                Button(action: {
                    print("something")
                    self.modalDisplayed    = true
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
                .sheet(isPresented: $modalDisplayed){
                    NewListView()
                }
                
                Button(action: {
                    print("something")
                    self.modalDisplayed    = true
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

            List{
                ForEach(itemCollection, id: \.self) { collection in
                    let imageURLs = collection.compositeImageURLs
                    let topLeftImage = UIImage.loadThumbnail(at: imageURLs[safe: 0], forSize: .small) ?? UIImage()
                    let topRightImage = UIImage.loadThumbnail(at: imageURLs[safe: 1], forSize: .small) ?? UIImage()
                    let bottomLeftImage = UIImage.loadThumbnail(at: imageURLs[safe: 2], forSize: .small) ?? UIImage()
                    let bottomRightImage = UIImage.loadThumbnail(at: imageURLs[safe: 3], forSize: .small) ?? UIImage()

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
                                    Image(uiImage: topRightImage)
                                        .resizable()
                                        .scaleEffect(1.1)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                }
                                HStack(spacing: 0) {
                                    Image(uiImage: bottomLeftImage)
                                        .resizable()
                                        .scaleEffect(1.1)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                    Image(uiImage: bottomRightImage)
                                        .resizable()
                                        .scaleEffect(1.1)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                }
                            }

                            VStack(alignment: .leading) {
                                Spacer()
                                    .frame(height: 5)
                                Text("\(collection.title ?? "")")
                                    .font(.headline)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                Spacer()
                                    .frame(height: 3)
                                Text("\(collection.subtitle ?? "")")
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
                                    Text("\(collection.author ?? "")")
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
            }
		}
	}
}
