//
//  ManifestItemsPickerView.swift
//  Landmarks
//
//  Created by Henry Huang on 3/21/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import SwiftUI
import CoreData

struct ManifestItemsPickerView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Manifest.sortedFetchRequest()) var manifestItems: FetchedResults<Manifest>
    @Binding var selectedManifests: [Manifest]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(manifestItems, id: \.self) { item in
                    let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        Text("\(item.itemLabel)")
                           .lineLimit(2)
                           .truncationMode(.tail)
                        Spacer()
                        Button(action: {
                            if let index = selectedManifests.firstIndex(of: item) {
                                selectedManifests.remove(at: index)
                            } else {
                                selectedManifests.append(item)
                            }
                        }, label: {
                            if selectedManifests.contains(item) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.green)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.green)
                                    .frame(width: 20, height: 20)
                            }
                        })
                    }
                }
            }
            .navigationTitle(Text("Select Items"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done") {
                        presentation.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
