//
//  WebView.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/22/20.
//

import Foundation
import SwiftUI

enum ActiveAlert{
    case first, third
}

struct CustomWebView:  View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var model = WebViewModel(link: "http://www.loc.gov")
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    
    var delegate: AssetRowProtocol?
    @State private var isError: Bool = true
    
    @Binding var presentedAsModal: Bool
    @State var isLoading: Bool = false
    @ObservedObject var alertFlag: AlertHandler = AlertHandler()
    @State private var test_flag: Bool = false
    
    var body: some View {
        ZStack(alignment: .center, content: {
            WebViewRepresentable(viewModel: model)
            ActivityIndicator(isAnimating: $isLoading, style: .large)
                .background(Color.white.frame(width: 200, height: 200, alignment: .center).opacity(0.2))
                .hidden(!isLoading)
                
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
            case .third:
                return Alert(title: Text("Website didn't load"), message: Text("This website did not load. Please wait or try another address"), dismissButton: .default(Text("OK")))
            }
        }
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

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
