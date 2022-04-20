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
    @State var navigationBarBackButtonHidden = false
    @State private var editMode = false
    @State private var showManifestItemsPickerView = false
    @State private var collectionItems: [Manifest] = []
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case titleField
        case subtitleField
        case creatorField
        case descriptionField
    }

    var body: some View {
        List {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                        .frame(height: 10)

                    // AlbumView
                    let imageURLs = collection.compositeImageURLs
                    AlbumView(imageSize: .medium,
                              topLeftImageURL: .constant(imageURLs[safe: 0]),
                              topRightImageURL: .constant(imageURLs[safe: 1]),
                              bottomLeftImageURL: .constant(imageURLs[safe: 2]),
                              bottomRightImageURL: .constant(imageURLs[safe: 3]))

                    // Title
                    if editMode {
                        TextField("Untitled List", text: $collection.title)
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.bold))
                            .submitLabel(.next)
                            .focused($focusedField, equals: .titleField)
                            .onSubmit {
                                focusedField = .subtitleField
                            }
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
                            .submitLabel(.next)
                            .focused($focusedField, equals: .subtitleField)
                            .onSubmit {
                                focusedField = .creatorField
                            }
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
                                .submitLabel(.next)
                                .focused($focusedField, equals: .creatorField)
                                .onSubmit {
                                    focusedField = .descriptionField
                                }
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
                    ZStack {
                        if collection.detail.isEmpty == true {
                            VStack {
                                HStack {
                                    Text("Description")
                                        .padding(.horizontal, 3.5)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        TextEditor(text: $collection.detail)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 100, maxHeight: .infinity)
                            .padding(.horizontal, -1.5)
                            .focused($focusedField, equals: .descriptionField)
                            .onChange(of: collection.detail, perform: { value in
                                if collection.detail == "\n" {
                                    collection.detail = ""
                                }
                            })
                    }
                }
            } else {
                if collection.detail != "" {
                    HStack {
                        Text("\(collection.detail)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(5)
                            .truncationMode(.tail)
                        Spacer()
                    }
                }
            }

            if editMode {
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
            }

            if !collectionItems.isEmpty {
                ForEach(collectionItems, id: \.self) { item in
                    let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()

                    if editMode {
                        HStack {
                            Button(action: {
                                if let index = collectionItems.firstIndex(of: item) {
                                    withAnimation(.spring()) {
                                        onDelete(offsets: IndexSet(integer: index))
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
                    } else {
                        NavigationLink(destination: LazyView(ContentView(imageURL: item.imageURL,
                                                                         width: (item.width),
                                                                         length: (item.length),
                                                                         labels: item.labels!,
                                                                         values: item.values! ))) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)

                            Text("\(item.itemLabel)")
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }
                }
                .onDelete(perform: onDelete)
                .onMove(perform: moveCollectionItems)
            } else if !editMode {
                Text("Empty List")
            }
        }
        .onAppear {
            collectionItems = (collection.items?.array as? [Manifest]) ?? []
        }
        .onChange(of: collectionItems) { saveIntoDB(updatedItems: $0) }
        .navigationBarBackButtonHidden(navigationBarBackButtonHidden)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        Task {
                            // Prepare collection archive
                            do {
                                let fileURL = try await DataExportHandler.prepareArchive(itemCollection: collection)
                                // Show share extension
                                openShareActionSheet(with: fileURL)
                            } catch {
                                print(error)
                            }
//                            do {
//                                let importCollection = try await DataExportHandler.importArchive(archiveURL: fileURL!, managedObjectContext: managedObjectContext)
//                                print(importCollection)
//                            } catch {
//                                print(error)
//                            }
                        }
                    }, label: {
                        if !editMode {
                            Image(systemName: "square.and.arrow.up")
                        }
                    })

                    Button(action: {
                        withAnimation {
                            editMode.toggle()
                            navigationBarBackButtonHidden.toggle()
                        }
                    }, label: {
                        if editMode {
                            Text("Done")
                        } else {
                            Image(systemName: "pencil.circle")
                        }
                    })
                }
            }
            ToolbarItem(placement: .keyboard) {
                Button {
                    focusedField = nil
                } label: {
                    Text("Close Keyboard")
                        .bold()
                }
            }
        }
    }

    private func moveCollectionItems(from source: IndexSet, to destination: Int) {
        collectionItems.move(fromOffsets: source, toOffset: destination)
    }

    private func onDelete(offsets: IndexSet) {
        collectionItems.remove(at: offsets.first!)
    }

    private func saveIntoDB(updatedItems: [Manifest]) {
        let updatedSet = NSOrderedSet(array: updatedItems)
        guard let setDifference = collection.items?.difference(from: updatedSet) as? NSOrderedCollectionDifference,
              setDifference.hasChanges else { return }

        collection.items = updatedSet
        do {
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }

    private func openShareActionSheet(with url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        let window = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        window?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}
