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
    var delegate: AssetRowProtocol?
    @Binding var presentedAsModal: Bool
    @Binding var hasJP2: Bool
    @Binding var label: String
    @State private var isAlert: Bool = false
    @State private var isActivity: Bool = false
    @State var text: String = "Adding to Booksnake"
    @State var activeAlert: ActiveAlert = .second
	@State var width: CGFloat = 1
	
//	@ObservedObject var successModel: SuccessObserver
	@State var opacityValue = 0.0
	@State var temp:Bool = false

    var webview: WebViewRepresentable

    var body: some View {
        ZStack{
            VStack{
                webview
                .onAppear(perform: {
//Option 1: progress bar
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
            
            Rectangle()
				.fill(temp ? Color.red : Color.init(white: 0.7))
                .frame(width: 200, height: 200, alignment: .center)
                .isHidden(!isActivity, remove:!isActivity)
                .opacity(0.7)
                .cornerRadius(5.0)

            ActivityIndicator(isAnimating: $isActivity, text: $text, style: .large)
        }
        .navigationBarItems(trailing: HStack(){
            Button(action: {
                var path = self.webview.viewModel.path
				
				if (path.isEmpty){
					DispatchQueue.main.asyncAfter(deadline: .now() + Double(5.0), execute: { path = self.webview.getPath() })
				}
				
				//var temp = false
                isActivity = true
				//DispatchQueue.main.asyncAfter(deadline: .now() + Double(5.0)){
					checkTextField(url: path, completion: { status in
						if (!status){
							activeAlert = .first
							isAlert = true
						}
						else {
							if !path.hasSuffix("manifest.json"){
								path.append("manifest.json")
							}
								self.delegate?.onAddEntry(path: path,  completion: { success in
									if (success) {
										print("sucess in downloading")
										activeAlert = .third
										isAlert = true
										return
									}
									else {
										activeAlert = .first
										isAlert = true
									}
									
								})
						}
						isActivity = false
					})
			//	}
            }, label: {
                Text("Add")
            })
			.disabled( self.webview.isJP2)
        })
        .alert(isPresented: $isAlert, content: {
            switch activeAlert{
                case .first:
                    return Alert(title: Text("Unable to add item"), message: Text("The item catalog page doesn't have the necessary information"), dismissButton: .default(Text("OK")))
                case .second:
                    return Alert(title: Text("Download failed"), message: Text("Something went wrong during download process. Check that manifest has necessary information and/or internet is working"), dismissButton: .default(Text("OK")))
                case .third:
                    return  Alert(title: Text(label + " Download Complete!"), message: Text("Swipe down to return to main page."), dismissButton: .default(Text("OK")))
            }
        })
    }
    
    func checkTextField(url : String, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var path: String = url
        
        if (url.isEmpty){
            completion(false)
            return
        }
        
        let url_filter = URL(string: path + "?fo=json&at=item.mime_type") ?? URL(string: "https://www.google.com")
        
        if !path.hasSuffix("manifest.json"){
            path.append("manifest.json")
        }
		DispatchQueue.main.async {
			let url_path = NSURL(string: path)
			let html = try! String(contentsOf: url_filter!)
		   
			if !UIApplication.shared.canOpenURL(url_path! as URL){
				completion(false)
			}
			//check that there is a jp2 tag
			else if (!html.contains("image/jp2")){
				print("no jp2")
				completion(false)
			}
			else {
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
			}
		}
	}
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
