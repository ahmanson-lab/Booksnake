//
//  AlertWrapper.swift
//  Landmarks
//
//  Created by Christy Ye on 10/31/20.
//  Copyright © 2020 University of Southern California. All rights reserved.

import SwiftUI

enum ActiveAlert {
    case first, second, third
}

struct CustomSearchMenu: View {
    @Binding var addDefaultURL: Bool
    @Binding var label: String
    @State var fieldValue = ""
    @State var hasText: Bool = true
	
    var delegate: AssetRowProtocol?
    
    var color1: Color = Color(red: 237/225, green: 30/225, blue: 52/225, opacity: 1)
    var color2: Color = Color(red: 40/225, green: 115/225, blue: 172/225, opacity: 1)
    var color3: Color = Color(red: 239/225, green: 79/225, blue: 38/225, opacity: 1)
	var color4: Color = Color(red: 51/225, green: 70/225, blue: 12/225, opacity: 1) //HDL
    
	var items: [GridItem] = Array(repeating: .init(.flexible(minimum: 300, maximum: 1000)), count: 1)
	
    var body: some View {
			ScrollView (.vertical, showsIndicators: false) {
				LazyVGrid(columns: items, alignment: .leading, spacing: 20) {
		//List {
			NavigationLink( destination: InputView( label: $label,hasText: $hasText, delegate: delegate),
				label: {
					Text("Add from IIIF Manifest")
						.fontWeight(.bold)
						.multilineTextAlignment(.center)
						.background(LinearGradient(gradient: Gradient(colors: [color2, color1]), startPoint: .bottomLeading, endPoint: .topTrailing)
										.frame(width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.width / 3, alignment: .center)
										.cornerRadius(10.0))
										.padding(.all, 10.0)
						.font(.title)
						.foregroundColor(.white)
						.frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width / 3, alignment: .center)
				})
			
				//LOC Catalogue
				NavigationLink(
					destination: CatalogSearchView(label: $label, title: "Library of Congress", type: "LOC", instructions: "Search results are limited to Library of Congress materials with an IIIF manifest, which Booksnake uses to add items.", filter: "gov/item", fieldURL: ["https://www.loc.gov/search/?q=", "&fa=mime-type:image/jp2"], delegate: delegate),
					label: {
						Text("Library of Congress")
							.fontWeight(.bold)
							.multilineTextAlignment(.center)
							.background(color3
											.frame(width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.width / 3, alignment: .center)
											.cornerRadius(10.0))
											.padding(.all, 10.0)
							.font(.title)
							.foregroundColor(.white)
						    .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width / 3, alignment: .center)
					})
				
				//Huntington Catalogue
				NavigationLink(
					destination: CatalogSearchView(label: $label, title: "Huntington Digital Library", type: "HDL", instructions: "Search results are limited to Huntington Digital Library materials with an IIIF manifest, which Booksnake uses to add items.", filter: "/id/", fieldURL: ["https://hdl.huntington.org/digital/search/collection/p15150coll8!p15150coll7!p15150coll4!p15150coll2!p15150coll3!p9539coll1!p16003coll13!p16003coll11!p16003coll14!p16003coll12!p16003coll4!p16003coll7!p16003coll10!p16003coll5!p16003coll18!p16003coll15!p15150coll5!p16003coll17!p16003coll2!p16003coll16!p16003coll6!p16003coll9/searchterm/"], delegate: delegate),
					label: {
						Text("Huntington Digital Library")
							.fontWeight(.bold)
							.multilineTextAlignment(.center)
							.background(color4
											.frame(width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.width / 3, alignment: .center)
											.cornerRadius(10.0))
											.padding(.all, 10.0)
							.font(.title)
							.foregroundColor(.white)
						   .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width / 3, alignment: .center)
					})
			}
        }
	}
    }

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}
