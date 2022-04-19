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
import CoreData

struct NewListView: View {
	@Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var collectionTitle: String = ""
    @State private var collectionSubtitle: String = ""
    @State private var collectionCreator: String = ""
    @State private var collectionDescription: String = ""
    @State private var collectionItems: [Manifest] = []
    @State private var showManifestItemsPickerView = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

	var body: some View {
        NavigationView {
            List {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                            .frame(height: 10)

                        // AlbumView
                        AlbumView(imageSize: .medium,
                                  topLeftImageURL: .constant(collectionItems[safe: 0]?.imageURL),
                                  topRightImageURL: .constant(collectionItems[safe: 1]?.imageURL),
                                  bottomLeftImageURL: .constant(collectionItems[safe: 2]?.imageURL),
                                  bottomRightImageURL: .constant(collectionItems[safe: 3]?.imageURL))

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
                
                Button(action: {
                    self.showManifestItemsPickerView = true
                }, label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.green)
                            .frame(width: 20, height: 20)
                        Text("Add Items")
                    }
                })
                .sheet(isPresented: $showManifestItemsPickerView) {
                    ManifestItemsPickerView(selectedManifests: $collectionItems)
                        .interactiveDismissDisabled(true)
                }

                ForEach(collectionItems, id: \.self) { item in
                    let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()
                    HStack {
                        Button(action: {
                            if let index = collectionItems.firstIndex(of: item) {
                                _ = withAnimation(.spring()) {
                                    collectionItems.remove(at: index)
                                }
                            }
                        }, label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                        })
                        .buttonStyle(PlainButtonStyle())
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        Text("\(item.itemLabel)")
                            .lineLimit(2)
                            .truncationMode(.tail)
                        Spacer()
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                    }
                    .onDrag {
                        return NSItemProvider()
                    }
                }
                .onMove(perform: moveCollectionItems)
            }
            .navigationTitle(Text("New List"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button("Cancel") {
                        presentation.wrappedValue.dismiss()
                    }.foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Use default name if title is unset
                        if collectionTitle == "" {
                            collectionTitle = "Untitled List"
                        }

                        // 1. Title formatted check
                        // 2. Empty item check
                        if isTitleExistedInDB(title: collectionTitle) {
                            alertTitle = "Title is existed"
                            alertMessage = "The title is existed in your collection, please rename the title."
                            showAlert = true
                        } else if collectionItems.isEmpty {
                            alertTitle = "No item is selected"
                            alertMessage = "Please at lease pick one item to create collection."
                            showAlert = true
                        } else if saveCollection() {
                            presentation.wrappedValue.dismiss()
                        } else {
                            alertTitle = "Database Error"
                            alertMessage = "Something wrong when saving collection, please try again later."
                            showAlert = true
                        }
                    } label: {
                        Text("Create")
                            .bold()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
		}
	}
    
    private func moveCollectionItems(from source: IndexSet, to destination: Int) {
        collectionItems.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveCollection() -> Bool {
        let collectionData = NSEntityDescription.insertNewObject(forEntityName: "ItemCollection", into: managedObjectContext) as! ItemCollection
        collectionData.createdDate = Date()
        collectionData.title = collectionTitle
        collectionData.subtitle = collectionSubtitle
        collectionData.author = collectionCreator
        collectionData.detail = collectionDescription
        collectionItems.forEach { $0.addToCollections(collectionData) }
        do {
            try managedObjectContext.save()
            return true
        }
        catch {
            print(error)
        }
        
        return false
    }
    
    private func isTitleExistedInDB(title: String) -> Bool {
        let request = ItemCollection.fetchRequest() as! NSFetchRequest<ItemCollection>
        let predicate = NSPredicate(format: "title = %@", title)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let count = try managedObjectContext.count(for: request)

            if count == 0 {
                // No match found
                return false
            }
            else{
                // The title has existed in DB
                return true
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return true
    }
}
