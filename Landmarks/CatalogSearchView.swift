//
//  CatalogSearchView.swift
//  Landmarks
//
//  Created by Christy Ye on 7/12/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import SwiftUI

struct CatalogSearchView: View {
//	@Binding var presentedAsModal: Bool
	@Binding var label: String
	
	//text in catalogue
	@State var title: String
	@State var type: String
	@State var description: String = "Search hundreds of thousands of historical manuscripts, maps, newpapers, and more."
	@State var fieldDescription: String = "Search titles, authors, places..."
	@State var instructions: String
	@State var filter: String
	@State var fieldURL: [String]
	
	@State private var fieldValue: String = ""
	@State var urlPath: String = ""
	@State private var isAlert: Bool = false
	@State private var activeAlert: ActiveAlert = .first
	@State private var isError: Bool = false
	
	@ObservedObject var model = WebViewModel()
	
	@State private var hasJP2: Bool = true
	@State private var hasBackList: Bool = false
	@State private var hasForwardList: Bool = false
	@State private var active: Bool = false
	
	var delegate: AssetRowProtocol?
	var body: some View {

			ZStack(alignment: .top, content: {
				Color.init(.systemGray6)

				VStack{
					Text(title)
						.font(.title)
						.fontWeight(.bold)
						.multilineTextAlignment(.center)
						.padding(.top, 25)
						
					Text(description)
						.font(.subheadline)
						.fontWeight(.light)
						.multilineTextAlignment(.center)
						.padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
					
					TextField(fieldDescription, text: $fieldValue, onEditingChanged: {_ in }, onCommit: {
						active  = true
					})
					.textContentType(.oneTimeCode)
					.keyboardType(.webSearch)
					.padding(.horizontal, 20.0)
					.multilineTextAlignment(.leading)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.foregroundColor(.gray)
					.font(.body)
					.padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
						
					Text(instructions)
						.font(.caption)
						.fontWeight(.regular)
						.foregroundColor(Color.gray)
						.multilineTextAlignment(.leading)
						.padding([.leading, .bottom, .trailing], 20.0)
					NavigationLink(
						destination: FullWebView(hasJP2: $hasJP2, label: $label, filter: filter, type: type, delegate: delegate, webview: WebViewRepresentable(search: fieldURL.joined(separator: fieldValue), path: $urlPath, isJP2: $hasJP2, filter: filter, hasBackList: $hasBackList, hasForwardList: $hasForwardList, viewModel: model)) , isActive: $active,
						label: {
							ZStack(){
								Color.init(.systemBlue)
									.frame(width: UIScreen.main.bounds.width - 40, height: 50, alignment: .center)
									.cornerRadius(10)
								Text("Search")
									.foregroundColor(.white)
									.font(.system(size: 18, weight: .medium, design: .default))
							}
						})
						.padding(.all, 10.0)
						.navigationBarTitle(active ? "Search" : "", displayMode: .inline)
						
					Spacer()
					
				}
			})
	}
}
