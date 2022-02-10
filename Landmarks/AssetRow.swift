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

protocol AssetRowProtocol {
    func switchToLibraryTab()
}

struct AssetRow: View, AssetRowProtocol {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Manifest.sortedFetchRequest()) var contentTest: FetchedResults<Manifest>
    @State private var tabSelection = 1
    @State private var showLoading: Bool = false

    var body: some View {
        ZStack {
            TabView(selection: $tabSelection) {
                NavigationView{
                    List{
                        ForEach(contentTest, id: \.self) { item in
                            let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()
                            NavigationLink(destination: LazyView(ContentView(imageURL: item.imageURL,
                                                                             width: (item.width),
                                                                             length: (item.length),
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
					RootListView(delegate: self)
						.navigationBarTitle("Lists")
				}
				.navigationViewStyle(StackNavigationViewStyle())
				.tabItem {
					Image(systemName: "list.bullet")
					Text("Lists")
				}
				.tag(2)

                NavigationView {
                    CustomSearchMenu(delegate: self)
                        .navigationBarTitle("Explore")
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
                .tag(3)
            }
            .task {
                // To add some demo items in the collection
                if(contentTest.count < 1) {
                    showLoading = true
                    await ManifestDataHandler.addExamples(managedObjectContext: managedObjectContext)
                    showLoading = false
                }
            }

            ZStack {
                ActivityIndicator(isAnimating: $showLoading, text: "Adding Some Samples", style: .large)
                    .frame(width: 200.0, height: 200.0, alignment: .center)
                    .background(Color(white: 0.7, opacity: 0.7))
                    .cornerRadius(20)
            }
            .isHidden(!showLoading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    // Delegate function
    func switchToLibraryTab() {
        // Switch back to Library tab
        tabSelection = 1
    }

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

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
