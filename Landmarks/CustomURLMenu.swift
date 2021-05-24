//
//  AlertWrapper.swift
//  Landmarks
//
//  Created by Christy Ye on 10/31/20.
//  Copyright © 2020 Christy Ye . All rights reserved.

import SwiftUI

enum ActiveAlert{
    case first, third
}

struct CustomURLMenu: View {
    @Environment(\.presentationMode) var presentation
    @Binding var presentedAsModal: Bool
  //  @Binding var progressPercent: CGFloat
    
    @Binding var addDefaultURL: Bool
    var delegate: AssetRowProtocol?
  //  @State var google_view = false
    
    @State var fieldValue = ""
    
    var color1: Color = Color(red: 237/225, green: 30/225, blue: 52/225, opacity: 1)
    var color2: Color = Color(red: 40/225, green: 115/225, blue: 172/225, opacity: 1)
    var color3: Color = Color(red: 239/225, green: 79/225, blue: 38/225, opacity: 1)
    
    var body: some View {
        ZStack{
            NavigationView {
                List {
                        NavigationLink(destination: InputView(showModal: $presentedAsModal,delegate: delegate), label: {
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

                        destination: URLInputView(presentedAsModal: $presentedAsModal, delegate: delegate),
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
    
    @State var fieldValue: String = ""
    @Binding var showModal: Bool
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    @State private var isError: Bool = false
    
    @State var hasJP2: Bool = true
    
    var delegate: AssetRowProtocol?
    var body: some View {

            ZStack(alignment: .top, content: {
                Color.init(.systemGray6).edgesIgnoringSafeArea(.all)

                VStack{
                    Text("Add from IIIF Manifest")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)
                        
                   // HStack(){
                        Text("Libraries, museums, and archives around the world use IIIF, the International Image Interoperability Framework, to share digitized archival materials.\n\nFor instructions on finding an item's IIIF manifest URL, visit")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 10, trailing: 20))
                        
                        Button(action: {
                            UIApplication.shared.open(URL(string:"https://guides.iiif.io")!)
                        }, label: {
                            Text(" guides.iiif.io.").font(.subheadline)
                        })
                        .buttonStyle(BorderlessButtonStyle())
//                    }

                    TextField("Enter IIIF manifest", text: $fieldValue)
                        .padding(.horizontal, 10.0)
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
                        .padding(.horizontal, 10.0)
                    
                }
                   
            })
            .navigationBarItems(trailing: HStack(){
                Button(action: {
                    checkTextField(url: fieldValue, completion: { status in
                        
                            if (status) {
                                if !fieldValue.hasSuffix("manifest.json"){
                                    fieldValue.append("/manifest.json")
                                }
                                self.delegate?.onAddEntry(path: fieldValue,  completion: {success in
                                    if (success){
                                        print("sucess in downloading")
                                      //  hasJP2 = false
                                    }
//                                    else{
//                                        self.activeAlert = .third
//                                        isAlert = true
//                                    }
                                })
                            }
                            isError = !status
                            self.showModal = !status    
                            self.activeAlert = .first
                            isAlert = !status
                        })
                }, label:{
                    Text("Add")
                })
                //.disabled(hasJP2)
                .alert(isPresented: $isAlert){
                        switch activeAlert{
                        case .first:
                            return Alert(title: Text("Unable to add item"), message: Text("The item catalog page doesn't have the necessary information"), dismissButton: .default(Text("OK")))
                        case .third:
                            return  Alert(title: Text("Website didn't load"), message: Text("This website did not load. Please wait or try another address"), dismissButton: .default(Text("OK")))
                        }
                    }
                })
    }
    
    func urlChange(_ tag: String) {
        checkTextField(url: tag, completion: {status in hasJP2 = !status})
    }
    
    func checkTextField(url : String, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var path: String = url
        //var path: String = url
        
        let url_filter = URL(string: path + "?fo=json&at=item.mime_type")
        //only for loc.gov
        if (!path.hasSuffix("manifest.json")  && !path.contains("loc.gov")){
            path.append("/manifest.json")
        }
        
        let url_path = NSURL(string: path)

        let html = try? String(contentsOf: url_filter!)
        if !UIApplication.shared.canOpenURL(url_path! as URL){
            completion(false)
        }
        //check that there is a jp2 tag
        else if (html?.contains("jp2") != nil) {
            if !(html!.contains("jp2")) {
                completion(false)
            }
        }
        else{
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
