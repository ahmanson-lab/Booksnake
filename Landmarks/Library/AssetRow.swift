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
	func closeOnboardingView()
}

struct AssetRow: View, AssetRowProtocol {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Manifest.sortedFetchRequest()) var manifestItems: FetchedResults<Manifest>
    @State private var tabSelection = 1
    @State private var showLoading: Bool = false
	@State private var showMiniOnboarding: Bool = false

    var body: some View {
        ZStack {
            NavigationView {
                TabView(selection: $tabSelection) {
                    // MARK: Tab 1 - Library Tab
                    List {
                        ForEach(manifestItems, id: \.self) { item in
                            let image = UIImage.loadThumbnail(at: item.imageURL, forSize: .small) ?? UIImage()
                            NavigationLink(destination: LazyView(ContentView(imageURL: item.imageURL,
                                                                             width: (item.width),
                                                                             length: (item.length),
                                                                             labels: item.labels!,
                                                                             values: item.values!))) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                Text("\(item.itemLabel)")
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }
                        }
                        .onDelete(perform: onDelete)
                    }
                    .toolbar(content: {
                        Button(action: {
                            showMiniOnboarding = true
                        }, label: {
                            Image(systemName:  "questionmark.circle").foregroundColor(.blue)
                        })
                    })
                    .tabItem {
                        Image(systemName: "scroll")
                        Text("Library")
                    }
                    .tag(1)

                    //MARK: Tab 2 - Lists
                    RootListView(delegate: self)
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("Lists")
                        }
                        .tag(2)

                    //MARK: Tab 3 - Explore
                    CustomSearchMenu(delegate: self)
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Explore")
                        }
                        .tag(3)
                }
                .navigationBarTitle(navigationBarTitle(tabSelection: tabSelection))
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .task {
                // To add some demo items in the collection
                if(manifestItems.count < 1) {
                    showLoading = true
                    await ManifestDataHandler.addExamples(managedObjectContext: managedObjectContext)
                    showLoading = false
                }
            }
            .disabled(showLoading)

			//MARK: Loading Indicator
            ActivityIndicator(isAnimating: $showLoading, text: "Adding Some Samples", style: .large)
                .frame(width: 200.0, height: 200.0, alignment: .center)
                .background(Color(white: 0.7, opacity: 0.7))
                .cornerRadius(20)
                .isHidden(!showLoading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

			//MARK: Onboarding View
			OnboardingView(delegate: self).isHidden(UserDefaults.standard.bool(forKey: "isOnboardingShowed"))
			
        }
		.sheet(isPresented: $showMiniOnboarding, content: {MiniOnboardingView(delegate: self) })
    }
	
	func closeOnboardingView(){
		showMiniOnboarding = false
	}

    // Delegate function
    func switchToLibraryTab() {
        // Switch back to Library tab
        tabSelection = 1
    }

    func navigationBarTitle(tabSelection: Int) -> String{
        switch tabSelection {
        case 1:
            return "Library"
        case 2:
            return "Lists"
        case 3:
            return "Explore"
        default:
            return ""
        }
    }

    private func onDelete(offsets: IndexSet) {
        guard let contentToDelete = manifestItems[safe: offsets.first!] else { return }
        managedObjectContext.delete(contentToDelete)
        do {
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
}
