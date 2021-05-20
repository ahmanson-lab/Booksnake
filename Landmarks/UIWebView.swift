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
    @Binding var hasJP2: Bool 
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    
    
    
    var webview: WebViewRepresentable // = WebViewRepresentable(flagModel: model)

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
                checkTextField(url: self.webview.link2.absoluteString, completion: {status in
                    //something
                })

            }, label: {
                Text("Add")
            }).disabled(webview.flagModel.isJP2)
        })
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
