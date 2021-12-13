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
    @FetchRequest(fetchRequest: Manifest.sortedFetchRequest()) var contentTest: FetchedResults<Manifest>

    @State var addDefaultURL = false
    @State var label: String = ""

    var body: some View {
        TabView {
            NavigationView{
                List{
                    ForEach(contentTest, id: \.self){ item in
                        let image = UIImage(contentsOfFile: item.imagePath ?? "") ?? UIImage()
                        NavigationLink(destination: LazyView(ContentView(image: image,
                                                                         width: CGFloat(item.width),
                                                                         length: CGFloat(item.length),
                                                                         labels: item.labels! ,
                                                                         values: item.values! ))) {
                            Image(uiImage: image)
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

            let contentdata = NSEntityDescription.insertNewObject(forEntityName: "Manifest", into: self.managedObjectContext) as! Manifest
            contentdata.id = new_manifest.id
            contentdata.labels = new_manifest.item.labels
            contentdata.values = new_manifest.item.values
            if let imageDirectory = FileHandler.imageDirectoryURL,
               let imagePath = FileHandler.save(data: new_manifest.image.jpegData(compressionQuality: 1.0) ?? Data(),
                                                toDirectory: imageDirectory,
                                                withFileName: "\(new_manifest.id).jpg")?.path {
                contentdata.imagePath = imagePath
            }
            contentdata.width = new_manifest.item.width ?? width
            contentdata.length = new_manifest.item.height ?? length
            contentdata.createdDate = Date()

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
                let contentdata = NSEntityDescription.insertNewObject(forEntityName: "Manifest", into: self.managedObjectContext) as! Manifest
                contentdata.id = new_manifest.id
                contentdata.labels = new_manifest.item.labels
                contentdata.values = new_manifest.item.values
                if let imageDirectory = FileHandler.imageDirectoryURL,
                   let imagePath = FileHandler.save(data: new_manifest.image.jpegData(compressionQuality: 1.0) ?? Data(),
                                                    toDirectory: imageDirectory,
                                                    withFileName: "\(new_manifest.id).jpg")?.path {
                    contentdata.imagePath = imagePath
                }
                contentdata.width = Float(sizes[index][1])
                contentdata.length = Float (sizes[index][0])
                contentdata.createdDate = Date()

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


struct FileHandler {
    private static var documentDirectoryPath: String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }

    static var imageDirectoryURL: URL? {
        let imageDir = URL(fileURLWithPath: Self.documentDirectoryPath).appendingPathComponent("Images")

        if !FileManager.default.fileExists(atPath: imageDir.path) {
            do {
                try FileManager.default.createDirectory(at: imageDir,
                                                        withIntermediateDirectories: true,
                                                        attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
            } catch {
                print("Can't create Document/Image folder.")
                return nil
            }
        }

        return imageDir
    }

    static func read(from directoryURL: URL, fileName: String) -> Data? {
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            let savedFile = try Data(contentsOf: fileURL)

            print("File saved at \(fileURL)")

            return savedFile
        } catch {
            print("Error reading saved file")
            return nil
        }
    }

    static func save(data: Data, toDirectory directory: URL, withFileName fileName: String) -> URL? {
        let fileURL = directory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL, options: .noFileProtection)
        } catch {
            print("Error", error)
            return nil
        }

        return fileURL
    }
}
