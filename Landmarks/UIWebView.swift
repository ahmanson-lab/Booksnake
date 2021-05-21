//
//  UIWebView.swift
//  Landmarks
//
//  Created by Christy Ye on 5/16/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SwiftUI

struct FullWebView : View {
    var delegate: AssetRowProtocol?
    @Binding var presentedAsModal: Bool
    @Binding var hasJP2: Bool 
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    
    var webview: WebViewRepresentable

    var body: some View {
        VStack{

            webview
            Spacer()
            
            HStack{
                Button(action: {
                    //do something
                    self.webview.goBack()
                }){
                    Text("back")
                }

                Spacer()

                Button(action: {
                    
                    self.webview.goForward()
                }){
                    Text("forward")
                }

            }
            Spacer()
        }
        .navigationBarItems(trailing: HStack(){
            Button(action: {
                var path = self.webview.viewModel.path
                
                checkTextField(url: path, completion: { status in
                    if (status){
                        if !path.hasSuffix("manifest.json"){
                            path.append("manifest.json")
                        }
                            self.delegate?.onAddEntry(path: path,  completion: {success in
                                if (success){
                                    print("sucess in downloading")
                                }
                            })
                        self.presentedAsModal = !status
                    }
                    else{
                        isAlert = true
                    }
                    
                })

            }, label: {
                Text("Add")
            }).disabled(self.webview.isJP2)
        })
        .alert(isPresented: $isAlert, content: {
            switch activeAlert{
                case .first:
                    return Alert(title: Text("Unable to add item"), message: Text("The item catalog page doesn't have the necessary information"), dismissButton: .default(Text("OK")))
                case .third:
                    return  Alert(title: Text("Website didn't load"), message: Text("This website did not load. Please wait or try another address"), dismissButton: .default(Text("OK")))
            }
        })
    }
    
    func checkTextField(url : String, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var path: String = url
        
        let url_filter = URL(string: path + "?fo=json&at=item.mime_type")
        
        if !path.hasSuffix("manifest.json"){
            path.append("manifest.json")
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
