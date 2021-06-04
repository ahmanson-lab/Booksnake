//
//  AssetRow.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/23/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

class AlertHandler: ObservableObject {
    @Published var isInvalidManifest: Bool = true
}

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
    @ObservedObject var alertFlag: AlertHandler = AlertHandler()
    @State private var editMode = EditMode.inactive
    
    @Environment(\.presentationMode) var presentation
    
    @FetchRequest(fetchRequest: ContentData.allIdeasFetchRequest()) var contentTest: FetchedResults<ContentData>
    
    @State var modalDisplayed = false
    @State var addDefaultURL = false
    
    @State var test_flag: Bool = false
    @State var numCells: Int = 0
    
    @State private var counter: Int = 0

    @State var new_labels: [String] =  [String]()
    @State var new_values: [String] =  [String]()
    
    var body: some View {
        NavigationView{
            List{
                ForEach(contentTest){ item in
                    NavigationLink(destination: ContentView(image: item.image, width: CGFloat(item.width), length: CGFloat(item.length), labels: item.labels!, values: item.values!)){
                        Image(uiImage: item.image ?? UIImage() )
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
            }
            .navigationBarTitle(Text("Archival Material"))
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.modalDisplayed = true
                self.alertFlag.isInvalidManifest = false
            },
            label: {
                Image("plus")
                    .resizable()
                    .frame(width: 20, height: 20)})
                .sheet(isPresented: $modalDisplayed){
                    CustomURLMenu(presentedAsModal: self.$modalDisplayed, addDefaultURL: $addDefaultURL, delegate: self)
            })
            .environment(\.editMode, $editMode)
        }
        .onAppear(perform: {
            //enter init data
            if(contentTest.count <= 0){
                addExamples()
            }
        })
    }
    
    //FOR DEMO: add hard coded values from local manifests and images
    func addExamples(){
        let new_item = ManifestData()
        let resource_paths = ["MapOfCalifornia", "MapOfLosAngeles", "TopographicLA", "LA1909", "AutomobileLA", "Hollywood"]
        let sizes = [[0.48, 0.69], [0.63, 0.56],[1.53, 0.56],[0.85, 1.02],[0.22, 0.08],[0.67, 0.66]]
        
        for i in 0...resource_paths.count - 1{
            if new_item.getLocalManifest(resource_name: resource_paths[i]){
                let new_manifest = ManifestItem(item:new_item, image: UIImage(named: resource_paths[i])!)
                let contentdata = NSEntityDescription.insertNewObject(forEntityName: "ContentData", into: self.managedObjectContext) as! ContentData
                contentdata.id = new_manifest.id
                contentdata.labels = new_manifest.item.labels
                contentdata.values = new_manifest.item.values
                contentdata.image = new_manifest.image
                contentdata.width = Float( sizes[i][0])
                contentdata.length = Float (sizes[i][1])
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

    //wrapper function for adding content from another view
    func onAddEntry(path: String, completion: (_ success: Bool) -> Void) {
        onAdd(path: path, completion: completion)
    }
    
    //add a default item from library of congress
    func onAdd(path: String, width: Float = 1, length: Float = 1, completion: (_ success: Bool) -> Void){
        print("here")
        test_flag = true
        let new_item = ManifestData()

        if new_item.getRemoteManifest(resource_name: path){
            let new_manifest = ManifestItem(item: new_item, image: new_item.image!)
            
            let contentdata = NSEntityDescription.insertNewObject(forEntityName: "ContentData", into: self.managedObjectContext) as! ContentData
            contentdata.id = new_manifest.id
            contentdata.labels = new_manifest.item.labels
            contentdata.values = new_manifest.item.values
            contentdata.image = new_manifest.image
            contentdata.width = width
            contentdata.length = length
            counter = counter + contentTest.count + 1
            contentdata.index = Int16(counter)
            
            //test
            contentdata.item_label = new_manifest.item.label
            
            do {
                try self.managedObjectContext.save()
            } catch {
                print(error)
            }
            test_flag = false
            completion(true)
        }
        completion(false)
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
}
