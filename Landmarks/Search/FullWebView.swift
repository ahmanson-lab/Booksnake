//
//  UIWebView.swift
//  Landmarks
//
//  Created by Christy Ye on 5/16/21.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SwiftUI

struct ProgressView: View {
	@Binding var width: CGFloat
	var body: some View {
		Rectangle()
			.fill(Color.blue)
			.frame(width: width, height: 10, alignment: .topLeading)
			.position(.init(x: 0, y: 0))
	}
}

struct FullWebView : View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @Binding var hasJP2: Bool
	@State var filter: String
	@State var type: String
	
    @State private var isAlert: Bool = false
    @State private var showLoading: Bool = false
    @State private var newItemLabel: String = ""
    @State var activeAlert: ActiveAlert = .second
	@State var width: CGFloat = 1
	@State var opacityValue = 0.0
	@State var temp: Bool = false
	@State var path: String = ""
	
	var delegate: AssetRowProtocol?
    var webview: WebViewRepresentable

    var body: some View {
        ZStack{
            VStack{
                webview
                .onAppear(perform: {
					for i in 1...5 {
						DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
							width = ( (2 * UIScreen.main.bounds.width / 5.0) * CGFloat(i))
						 }
					}
                })
                Spacer()
                HStack{
                    Button(action: {
                        self.webview.goBack()
                    }){
                        Image(systemName: "chevron.left")
                    }
                    .padding(.horizontal)
                    .disabled(!self.webview.hasBackList)
                    Spacer()
                    Button(action: {
                        self.webview.goForward()
                    }){
                        Image(systemName: "chevron.right")
                    }
                    .padding(.horizontal)
                    .disabled(!self.webview.hasForwardList)
                }
                Spacer()
            }
			ProgressView(width: $width)
            
            ZStack {
                ActivityIndicator(isAnimating: $showLoading, text: "Adding to Booksnake", style: .large)
                    .frame(width: 200.0, height: 200.0, alignment: .center)
                    .background(Color(white: 0.7, opacity: 0.7))
                    .cornerRadius(20)
            }
            .isHidden(!showLoading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .navigationBarItems(trailing: HStack(){
            Button(action: {
				downloadItem(type: type)
            }, label: {
                Text("Add")
            })
			.disabled(self.webview.isJP2)
        })
        .alert(isPresented: $isAlert, content: {
            switch activeAlert{
            case .first:
                return Alert(title: Text("Unable to add item"),
                             message: Text("The item catalog page doesn't have the necessary information"),
                             dismissButton: .default(Text("OK")))
            case .second:
                return Alert(title: Text("Download failed"),
                             message: Text("Something went wrong during download process. Check that manifest has necessary information and/or internet is working"),
                             dismissButton: .default(Text("OK")))
            case .third:
                return  Alert(title: Text("\(newItemLabel) Download Complete!"),
                              message: Text("Tap OK to return to main page."),
                              dismissButton: .default(Text("OK"), action: {
                    delegate?.switchToLibraryTab()
                }))
            }
        })
    }
	
    private func downloadItem(type: String) {
        showLoading = true

        if (type == "LOC") {
            path = self.webview.viewModel.path

            Task {
                defer {
                    isAlert = true
                    showLoading = false
                }

                // Check if url is valid for ifff
                let status = await validateURLForIIIF(url: path, filter: "?fo=json&at=item.mime_type")

                guard status else {
                    activeAlert = .first
                    return
                }

                // treat URL depending on Catalogue
                if !path.hasSuffix("manifest.json") {
                    path.append("manifest.json")
                }

                let result = await ManifestDataHandler.addNewManifest(from: path, managedObjectContext: self.managedObjectContext)

                switch result {
                case .success(let newItemLabel):
                    print("success in downloading")
                    self.newItemLabel = newItemLabel
                    activeAlert = .third
                case .failure(let error):
                    print("can't download manifest. Error \(error)")
                    activeAlert = .first
                }
            }
        }
        else if (type == "HDL"){
            //download process for Huntington
            path = self.webview.viewModel.path

            Task {
                defer {
                    isAlert = true
                    showLoading = false
                }

                // Check if url is valid for ifff
                let status = await validateURLForIIIF(url: path, filter: "/id/")

                guard status,
                      let collection = path.range(of: "collection/") else {
                          activeAlert = .first
                          return
                      }

                let indexA = path[collection.upperBound...].firstIndex(of: "/")
                let collection_id = path[collection.upperBound..<indexA!]

                let indexB = path[path.range(of: "id/")!.upperBound...].firstIndex(of: "/")
                let item_id = path[path.range(of: "id/")!.upperBound..<indexB!]

                let itemURL = "https://hdl.huntington.org/iiif/info/" + collection_id + "/" + item_id + "/manifest.json"

                let result = await ManifestDataHandler.addNewManifest(from: itemURL, managedObjectContext: self.managedObjectContext)

                switch result {
                case .success(let newItemLabel):
                    print("success in downloading")
                    self.newItemLabel = newItemLabel
                    activeAlert = .third
                    self.delegate?.switchToLibraryTab()
                case .failure(let error):
                    print("can't download manifest. Error \(error)")
                    activeAlert = .first
                }
            }
		}
	}

    private func validateURLForIIIF(url: String, filter: String) async -> Bool {
        var path: String = url

        guard !url.isEmpty else {
            return false
        }

        let url_filter = URL(string: path + filter) ?? URL(string: "https://www.google.com")

        if !path.hasSuffix("manifest.json") {
            path.append("manifest.json")
        }

        let url_path = NSURL(string: path)

        guard let html = try? String(contentsOf: url_filter!) else {
            return false
        }

        if await !UIApplication.shared.canOpenURL(url_path! as URL) {
            // No need to switch to Mainthread because UIApplication has @MainActor
            return false
        }
        else if (!html.contains("image/jp2") && !html.contains("@context") && type == "LOC") {
            //check that there is a jp2 tag
            print("no jp2")
            return false
        }
        else {
            var request = URLRequest(url: url_path! as URL)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 1.0

            guard let (_, response) = try? await URLSession.shared.data(for: request),
                  let httpResp: HTTPURLResponse = response as? HTTPURLResponse else {
                      return false
                  }

            return httpResp.statusCode == 200
        }

    }
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        }
		else {
            self
        }
    }
}
