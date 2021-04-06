//
//  WebView.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/22/20.
//

import Foundation
import SwiftUI

enum ActiveAlert{
    case first, second, third
}

struct CustomWebView:  View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var model = WebViewModel(link: "https://www.google.com/")
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    
    var url_string = ""
    var delegate: AssetRowProtocol?
    @State private var isError: Bool = true
    
    @Binding var presentedAsModal: Bool
    @State var isLoading: Bool
    @ObservedObject var alertFlag: AlertHandler = AlertHandler()
    @State private var test_flag: Bool = false
    
    init(path: String, delegate: AssetRowProtocol, presentedAsModal: Binding<Bool>) {
        _presentedAsModal = presentedAsModal
        _isLoading = State<Bool>.init(initialValue: false)
        url_string = path
        model.link = url_string
        
        self.delegate = delegate
    }
    
    var body: some View {
        ZStack(alignment: .center, content: {
            WebViewRepresentable(viewModel: model)
        })
        .navigationBarItems(trailing: HStack(){
            Button(action: {
                isLoading = true
                    if model.didFinishLoading {
                       // print("link", model.link)
                        var path = model.link
                        checkTextField(url: path, completion: {status in
                            //isError = status
                            if (status){
                                if !path.hasSuffix("manifest.json"){
                                    path.append("/manifest.json")
                                }
                                self.delegate?.onAddEntry(path: path, completion: {success in
                                    if (success){
                                        presentedAsModal = false
                                        isLoading = false
                                        
                                    }
                                })
                                
                                if ( alertFlag.isInvalidManifest){
                                    self.activeAlert = .first
                                    isAlert = true
                                }
                                else{
                                    presentedAsModal = false
                                }
                            }
                            else{
                                self.activeAlert = .first
                                isAlert = true
                            }
                        })
                    }
                    else{
                        isAlert = true
                        self.activeAlert = .third
                    }
            },
            label: {
                Text("Add")
            }).disabled(model.didChange)
        })
        .alert(isPresented: $isAlert){
            switch activeAlert{
            case .first:
                return Alert(title: Text("Unable to add item"), message: Text("The item catalog page doesn't have the necessary information"), dismissButton: .default(Text("OK")))
            case .second:
                return Alert(title: Text("Unsupported Item"), message: Text("The item manifest is missing values and/or has incorrect metadata values"), dismissButton: .default(Text("OK")))
            case .third:
                return Alert(title: Text("Website didn't load"), message: Text("This website did not load. Please wait or try another address"), dismissButton: .default(Text("OK")))
            }
        }
        ActivityIndicator(isAnimating: $isLoading, style: .large)
    }
    
    func checkTextField(url : String, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var path: String = url
        
        let url_filter = URL(string: path + "?fo=json&at=item.mime_type")
        //only for loc.gov
        if !path.hasSuffix("manifest.json"){
            path.append("/manifest.json")
        }
        
        let url_path = NSURL(string: path)

        let html = try! String(contentsOf: url_filter!)
       
        if !UIApplication.shared.canOpenURL(url_path! as URL){
            completion(false)
        }
        //check that there is a jp2 tag
        else if (!html.contains("jp2")){
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
