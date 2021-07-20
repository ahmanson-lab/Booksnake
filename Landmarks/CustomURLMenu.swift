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

struct CustomURLMenu: View {
    @Environment(\.presentationMode) var presentation
    @Binding var presentedAsModal: Bool
    @Binding var addDefaultURL: Bool
    @Binding var label: String
    @State var fieldValue = ""
    @State var hasText: Bool = true
    var delegate: AssetRowProtocol?
    
    var color1: Color = Color(red: 237/225, green: 30/225, blue: 52/225, opacity: 1)
    var color2: Color = Color(red: 40/225, green: 115/225, blue: 172/225, opacity: 1)
    var color3: Color = Color(red: 239/225, green: 79/225, blue: 38/225, opacity: 1)
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    NavigationLink(destination: InputView(showModal: $presentedAsModal, label: $label,hasText: $hasText, delegate: delegate), label: {
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
                    NavigationLink(
                        destination: URLInputView(presentedAsModal: $presentedAsModal, label: $label, delegate: delegate),
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
                }
                .navigationBarTitle(Text("Add Item"), displayMode: NavigationBarItem.TitleDisplayMode.inline)
                .navigationBarItems(trailing: HStack(){
                    Button(action: {
                        self.presentedAsModal = false
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("Cancel").foregroundColor(.red)
                    }
                })
            }
        }
    }
}

struct InputView: View {
    @Binding var showModal: Bool
    @Binding var label: String
    @State var text: String = "Adding to Booksnake"
    
    @State var fieldValue: String = ""
    @State var isAlert: Bool = false
    @State var activeAlert: ActiveAlert = .first
    @State private var isError: Bool = false
    @State private var isActivity: Bool = false
    
    @Binding var hasText: Bool
    
    var delegate: AssetRowProtocol?
    var body: some View {

        ZStack(alignment: .top, content: {
                Color.init(.systemGray6)

                VStack{
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
							self.showModal = false
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

		let url_filter = URL(string: url + "?fo=json&at=item.mime_type") ?? URL(string: "https://www.google.com")
        let html = try? String(contentsOf: url_filter!)
   
        //check that there is a jp2 tag
        if (html?.contains("jp2") != nil) {
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
        }
    }
}

struct SuccessView: View {
	@Binding var opacityValue: Double
	//@ObservedObject var successModel: SuccessObserver
	
	var body: some View {
		HStack{
			Rectangle()
				.fill(Color.red)
				.frame(width: 200, height: 200, alignment: .center)
				.opacity(opacityValue)
				.cornerRadius(5.0)
				
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
