//
//  AlertWrapper.swift
//  Landmarks
//
//  Created by Christy Ye on 10/31/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.

import SwiftUI

struct CustomURLMenu: View {
    @Environment(\.presentationMode) var presentation
    @Binding var presentedAsModal: Bool
    @Binding var progressPercent: CGFloat
    //@ObservedObject var alertFlag: AlertHandler
    @Binding var addDefaultURL: Bool
    var delegate: AssetRowProtocol?
    @State var google_view = false
    
    @State var fieldValue = "something"
    var body: some View {
        ZStack{
            NavigationView {
                List {
                    Section(header: Text("A")){
                        NavigationLink(destination: InputView(showModal: $presentedAsModal,progressPercent: $progressPercent, delegate: delegate), label: {
                            Text("Add from URL")
                        })
                    }
                    Section(header: Text("D")){
                        Button(action: {
                            self.delegate?.onAddEntry(path: "https://www.loc.gov/item/2009579466/manifest.json",  completion: { success in
                                if (success){
                                    self.presentedAsModal = false
                                }
                                self.addDefaultURL = !success
                            })
                        }) {
                            Text("Demo: Add example resource from Library of Congress")
                        }
                    }
                    Section(header: Text("L")){
                        NavigationLink(
                            destination: CustomWebView(path: "http://www.loc.gov", delegate: delegate!, presentedAsModal: $presentedAsModal),
                            label: {
                                Text("Library of Congress")
                            })
                    }
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
    
    @State var fieldValue:String = ""
    @Binding var showModal: Bool
    @Binding var progressPercent: CGFloat
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    @State private var isError: Bool = false
    
    var delegate: AssetRowProtocol?
    var body: some View {

            ZStack(alignment: .top, content: {
                Color.init(.systemGray5).edgesIgnoringSafeArea(.all)

                TextField("Enter URL for item catalog page", text: $fieldValue)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
                   
            })
            .navigationBarItems(trailing: HStack(){
                Button(action: {
                    checkTextField(url: fieldValue, completion: { status in
                        print("fieldvalue is ",fieldValue)
                            if (status) {
                                if !fieldValue.hasSuffix("manifest.json"){
                                    fieldValue.append("/manifest.json")
                                }
                                self.delegate?.onAddEntry(path: fieldValue,  completion: {success in
                                    if (success){
                                        print("sucess in downloading")
                                    }
                                    else{
                                        self.activeAlert = .third
                                        isAlert = true
                                    }
                                })
                            }
                            isError = !status
                            self.showModal = !status    
                            self.activeAlert = .first
                            isAlert = !status
                        })
                    }){
                        Text("Add")
                    }.alert(isPresented: $isAlert){
                        switch activeAlert{
                        case .first:
                            return Alert(title: Text("Unable to add item"), message: Text("The item catalog page doesn't have the necessary information"), dismissButton: .default(Text("OK")))
                        case .second:
                            return  Alert(title: Text("Unsupported Item"), message: Text("The item manifest is missing values and/or has incorrect metadata values"), dismissButton: .default(Text("OK")))
                        case .third:
                            return  Alert(title: Text("Website didn't load"), message: Text("This website did not load. Please wait or try another address"), dismissButton: .default(Text("OK")))
                        }
                    }
                })
    }
    
    func checkTextField(url : String, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var path: String = url
        
        //only for loc.gov
        if !path.hasSuffix("manifest.json"){
            path.append("/manifest.json")
        }
        
        let url_path = NSURL(string: path)
        
    
        if !UIApplication.shared.canOpenURL(url_path! as URL){
            completion(false)
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
