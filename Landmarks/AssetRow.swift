//
//  AssetRow.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/23/20.
//  Copyright © 2020 University of Southern California. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

//don't use this struct in view
struct ManifestItem: Identifiable {
    let id = UUID()
    let item: ManifestData
    let image: UIImage
}

protocol AssetRowProtocol {
    func onAddEntry(path: String, completion: (_ success: Bool) -> Void)
}

struct AssetRow: View, AssetRowProtocol {

    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var editMode = EditMode.inactive
    @FetchRequest(fetchRequest: ContentData.allIdeasFetchRequest()) var contentTest: FetchedResults<ContentData>

    @State var addDefaultURL = false
    @State var label: String = ""
    @State private var counter: Int = 0

    var body: some View {
        TabView {
            NavigationView{
                List{
                    ForEach(contentTest, id: \.self){ item in
                        NavigationLink(destination: LazyView(ContentView(image: UIImage(data: item.imageData!) ?? UIImage(),
                                                                         width: CGFloat(item.width),
                                                                         length: CGFloat(item.length),
                                                                         labels: item.labels! ,
                                                                         values: item.values! ))) {
                            Image(uiImage: UIImage(data: item.imageData!) ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)

                            //item label
                            Text("\(item.item_label ?? "")")
                               .lineLimit(2)
                               .truncationMode(.tail)
                        }
                    }
                    .onDelete(perform: onDelete)
                }.navigationBarTitle("Library")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "scroll")
                Text("Library")
            }

            NavigationView {
                CustomSearchMenu(addDefaultURL: $addDefaultURL, label: $label, delegate: self)
                    .navigationBarTitle("Explore")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }
            .environment(\.editMode, $editMode)
            .id(UUID())
        }
        .onAppear(perform: {
            if(contentTest.count < 1){
                addExamples()
            }
        })
    }

    //wrapper function for adding content from another view
    func onAddEntry(path: String, completion: (_ success: Bool) -> Void) {
        onAdd(path: path, completion: completion)
    }

    //add a iiif item from library of congress
    func onAdd(path: String, width: Float = 1, length: Float = 1, completion: (_ success: Bool) -> Void){
        print("Remote Manifest Added")

        if let new_item = ManifestDataHandler.getRemoteManifest(from: path) {
            let new_manifest = ManifestItem(item: new_item, image: new_item.image!)

            let contentdata = NSEntityDescription.insertNewObject(forEntityName: "ContentData", into: self.managedObjectContext) as! ContentData
            contentdata.id = new_manifest.id
            contentdata.labels = new_manifest.item.labels
            contentdata.values = new_manifest.item.values
            contentdata.imageData = new_manifest.image.jpegData(compressionQuality: 1.0)
            contentdata.width = new_manifest.item.width ?? width
            contentdata.length = new_manifest.item.height ?? length
            counter = counter + contentTest.count + 1
            contentdata.index = Int16(counter)

            //test
            contentdata.item_label = new_manifest.item.label
            self.label = new_manifest.item.label

            do {
                try self.managedObjectContext.save()
            } catch {
                print(error)
            }
            return completion(true)
        }

        return completion(false)
    }

    //can delete items
    private func onDelete(offsets: IndexSet) {
        let contentToDelete = contentTest[offsets.first!]
        self.managedObjectContext.delete(contentToDelete)
        do {
            try self.managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }


    //FOR DEMO: add hard coded values from local manifests and images
    func addExamples() {
        let resource_paths = ["MapOfCalifornia", "MapOfLosAngeles", "TopographicLA", "LA1909", "AutomobileLA", "Hollywood"]
        let sizes = [[0.48, 0.69], [0.63, 0.56],[1.53, 0.56],[0.85, 1.02],[0.22, 0.08],[0.67, 0.66]]

        for index in 0..<resource_paths.count {
            if let new_item = ManifestDataHandler.getLocalManifest(from: resource_paths[index]) {
                let new_manifest = ManifestItem(item:new_item, image: UIImage(named: resource_paths[index])!)
                let contentdata = NSEntityDescription.insertNewObject(forEntityName: "ContentData", into: self.managedObjectContext) as! ContentData
                contentdata.id = new_manifest.id
                contentdata.labels = new_manifest.item.labels
                contentdata.values = new_manifest.item.values
                contentdata.imageData = new_manifest.image.jpegData(compressionQuality: 1.0)
                contentdata.width = Float(sizes[index][1])
                contentdata.length = Float (sizes[index][0])
                counter = counter + contentTest.count + 1
                contentdata.index = Int16(counter)

                //test
                contentdata.item_label = new_manifest.item.label

                do {
                    try self.managedObjectContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
