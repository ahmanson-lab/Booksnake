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
	//let image_url: String
}

protocol AssetRowProtocol {
    func switchToLibraryTab()
}

struct AssetRow: View, AssetRowProtocol {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Manifest.sortedFetchRequest()) var contentTest: FetchedResults<Manifest>
    @State private var tabSelection = 1

    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView{
                List{
                    ForEach(contentTest, id: \.self) { item in
                        let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()
                        NavigationLink(destination: LazyView(ContentView(imageURL: item.imageURL,
                                                                         width: CGFloat(item.width),
                                                                         length: CGFloat(item.length),
                                                                         labels: item.labels! ,
                                                                         values: item.values! ))) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)

                            //item label
                            Text("\(item.itemLabel ?? "")")
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
            .tag(1)

            NavigationView {
                CustomSearchMenu(delegate: self)
                    .navigationBarTitle("Explore")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }
            .tag(2)
        }
        .onAppear(perform: {
            // To add some demo items in the collection
            if(contentTest.count < 1){
                ManifestDataHandler.addExamples(managedObjectContext: managedObjectContext)
            }
        })
    }

    // Delegate function
    func switchToLibraryTab() {
        // Switch back to Library tab
        tabSelection = 1
    }
//<<<<<<< HEAD
//
//    //add a iiif item from library of congress
//    func onAdd(path: String, width: Float = 1, length: Float = 1, completion: (_ success: Bool) -> Void){
//        print("Remote Manifest Added")
//        test_flag = true
//
//		if let new_item = ManifestDataHandler.getRemoteManifest(from: path){
//			let new_manifest = ManifestItem(item: new_item, image: new_item.image!)
//
//            let contentdata = NSEntityDescription.insertNewObject(forEntityName: "ContentData", into: self.managedObjectContext) as! ContentData
//            contentdata.id = new_manifest.id
//            contentdata.labels = new_manifest.item.labels
//            contentdata.values = new_manifest.item.values
//			//contentdata.image_url = new_manifest.image_url
//            contentdata.imageData = new_manifest.image.jpegData(compressionQuality: 1.0)
//            contentdata.width = new_manifest.item.width ?? width
//            contentdata.length = new_manifest.item.height ?? length
//            counter = counter + contentTest.count + 1
//            contentdata.index = Int16(counter)
//
//            //test
//            contentdata.item_label = new_manifest.item.label
//            self.label = new_manifest.item.label
//
//            do {
//                try self.managedObjectContext.save()
//            } catch {
//                print(error)
//            }
//            test_flag = false
//            return completion(true)
//        }
//=======
//>>>>>>> b57288381a43f3ad7a4813b2a18ec669696655a2

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
}
//
//<<<<<<< HEAD
//
//    //FOR DEMO: add hard coded values from local manifests and images
//    func addExamples() {
//        let resource_paths = ["MapOfCalifornia", "MapOfLosAngeles", "TopographicLA", "LA1909", "AutomobileLA", "Hollywood"]
//        let sizes = [[0.48, 0.69], [0.63, 0.56],[1.53, 0.56],[0.85, 1.02],[0.22, 0.08],[0.67, 0.66]]
//
//        for index in 0..<resource_paths.count {
//            if let new_item = ManifestDataHandler.getLocalManifest(from: resource_paths[index]) {
//				let new_manifest = ManifestItem(item:new_item, image: UIImage(named: resource_paths[index])!)
//                let contentdata = NSEntityDescription.insertNewObject(forEntityName: "ContentData", into: self.managedObjectContext) as! ContentData
//                contentdata.id = new_manifest.id
//                contentdata.labels = new_manifest.item.labels
//                contentdata.values = new_manifest.item.values
//                contentdata.imageData = new_manifest.image.jpegData(compressionQuality: 1.0)
//                contentdata.width = Float(sizes[index][1])
//                contentdata.length = Float (sizes[index][0])
//                counter = counter + contentTest.count + 1
//                contentdata.index = Int16(counter)
//
//                //test
//                contentdata.item_label = new_manifest.item.label
//
//                do {
//                    try self.managedObjectContext.save()
//                }
//                catch {
//                    print(error)
//                }
//            }
//        }
//=======
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
