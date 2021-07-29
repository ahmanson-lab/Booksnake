//
//  InputView.swift
//  Landmarks
//
//  Created by Christy Ye on 7/24/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import SwiftUI

struct InputView: View {
//	@Binding var showModal: Bool
	@Binding var label: String
	@Binding var hasText: Bool
	
	@State var text: String = "Adding to Booksnake"
	@State var fieldValue: String = ""
	@State var isAlert: Bool = false
	@State var activeAlert: ActiveAlert = .first
	@State private var isError: Bool = false
	@State private var isActivity: Bool = false
	
	var delegate: AssetRowProtocol?
	
	var body: some View {

		ZStack(alignment: .top, content: {
				Color.init(.systemGray6)
				VStack {
					Text("Add from IIIF Manifest")
						.font(.title)
						.fontWeight(.bold)
						.multilineTextAlignment(.center)
						.padding(.top, 25)
						
						Text("Libraries, museums, and archives around the world use IIIF, the International Image Interoperability Framework, to share digitized archival materials.\n\nFor instructions on how to find an item's IIIF manifest URL in different archives, visit:")
							.font(.subheadline)
							.multilineTextAlignment(.center)
							.padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
						
						Button(action: {
								UIApplication.shared.open(URL(string:"https://guides.iiif.io")!)
							}, label: {
								Text("https://guides.iiif.io.").font(.subheadline)
						})
						.buttonStyle(BorderlessButtonStyle())
						
					TextField("Enter IIIF manifest URL", text: $fieldValue, onEditingChanged: { _ in
						  }, onCommit: {
							  urlEnter()
						})
					.padding(.horizontal, 20.0)
					.multilineTextAlignment(.leading)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.foregroundColor(.gray)
					.font(.body)
					.padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
					  
					Text("Type or paste an item's IIIF manifest URL to add it to Booksnake.")
						.font(.caption)
						.fontWeight(.regular)
						.foregroundColor(Color.gray)
						.multilineTextAlignment(.leading)
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
				}
				ZStack(alignment: .center, content: {
						Rectangle()
							.fill(Color.init(white: 0.7))
							.frame(width: 200, height: 200, alignment: .center)
							.isHidden(!isActivity)
							.opacity(0.7)
							.cornerRadius(5.0)
					ActivityIndicator(isAnimating: $isActivity, text: $text, style: .large)
				}).position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 3)
			})
			.navigationBarItems(trailing: HStack() {
				Button(action: {
					urlEnter()
				}, label:{
					Text("Add")
				})
				.disabled(!hasText)
				.alert(isPresented: $isAlert) {
						switch activeAlert {
						case .first:
							return Alert(title: Text("Unable to add item"), message: Text("The item catalog page doesn't have the necessary information"), dismissButton: .default(Text("OK")))
						case .second:
							return Alert(title: Text("URL has spaces and/or nothing is entered"), message: Text("Please remove spaces from URL address and/or type something"), dismissButton: .default(Text("OK")))
						case .third:
							return Alert(title: Text(label + " Download Complete!"), message: Text("Swipe down to return to main page."), dismissButton: .default(Text("OK")))
						}
				}
			})
	}
	
	func urlEnter() {
		if (!fieldValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
			checkTextField(url: fieldValue, completion: { status in
				isActivity = true
				if (status) {
					if (!fieldValue.hasSuffix("manifest.json") && fieldValue.contains("loc.gov")) {
						fieldValue.append("/manifest.json")
					}
					self.delegate?.onAddEntry(path: fieldValue,  completion: { success in
						if (success){
							print("sucess in downloading")
						  //  activeAlert = .third
//							self.showModal = false
							return
						}
					 //   isAlert = true
					})
				}
				else {
					activeAlert = .first
					isAlert = true
				}
				isError = !status
				isActivity = false
			})
		}
		else {
			activeAlert = .second
			isAlert = true
		}
	}
	
	func checkTextField(url : String, completion: @escaping (Bool) -> Void) {
		let checkSession = Foundation.URLSession.shared
		var path: String = url

		//only for loc.gov
		if (!path.hasSuffix("manifest.json")  && path.contains("loc.gov")){
			path.append("/manifest.json")
		}
		
		let url_path = NSURL(string: path)
		
		if (url.isEmpty || url_path == nil){
			completion(false)
			return
		}
		if !UIApplication.shared.canOpenURL((url_path!) as URL){
			completion(false)
			return
		}

//		let url_filter = URL(string: url + "?fo=json&at=item.mime_type") ?? URL(string: "https://www.google.com")
//		let html = try? String(contentsOf: url_filter!)
//
//		//check that there is a jp2 tag
//		if (html?.contains("jp2") != nil) {
//            if (!(html!.contains("jp2")) && path.contains("loc.gov")) {
//                completion(false)
//            }
//            else {
				var request = URLRequest(url: url_path! as URL)
				request.httpMethod = "HEAD"
				request.timeoutInterval = 1.0

				let task = checkSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
					if let httpResp: HTTPURLResponse = response as? HTTPURLResponse {
						completion(httpResp.statusCode == 200)
					}
					else{
						completion(false)
					}
				})
				task.resume()
		  //  }
//		}
	}
}
