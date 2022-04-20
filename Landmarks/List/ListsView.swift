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
    @State private var showImporter = false
	
	var body: some View {
		VStack {
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
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(18)
                .sheet(isPresented: $showNewListView){
                    NewListView()
                        .interactiveDismissDisabled(true)
                }
                
                Spacer()
                    .frame(width: 20)
                
                Button(action: {
                    showImporter = true
                }, label: {
                    Image(systemName: "link.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("Import List")
                })
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(18)
            }

            List {
                ForEach(itemCollections, id: \.self) { collection in
                    let imageURLs = collection.compositeImageURLs
                    NavigationLink(destination: LazyView(ListDetailView(collection: collection))) {
                        HStack(spacing: 14) {
                            // AlbumView
                            AlbumView(imageSize: .small,
                                      topLeftImageURL: .constant(imageURLs[safe: 0]),
                                      topRightImageURL: .constant(imageURLs[safe: 1]),
                                      bottomLeftImageURL: .constant(imageURLs[safe: 2]),
                                      bottomRightImageURL: .constant(imageURLs[safe: 3]))

                            // SideContentView
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
		}.fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.zip],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFileURL: URL = try result.get().first else { return }
                Task {
                    guard selectedFileURL.startAccessingSecurityScopedResource() else { return }

                    try await DataExportHandler.importArchive(archiveURL: selectedFileURL, managedObjectContext: managedObjectContext)

                    selectedFileURL.stopAccessingSecurityScopedResource()
                }
            } catch {
                print(error)
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
