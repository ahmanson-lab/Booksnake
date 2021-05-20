//
//  ARQuickLook.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/22/20.
//
//

import WebKit
import UIKit
import SwiftUI

class WebViewModel: ObservableObject {
    @Published var isJP2: Bool
    init() {
        isJP2 = false
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    @ObservedObject var flagModel: WebViewModel
    @State var link2: URL = URL(string: "https://www.loc.gov")!
    
    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<WebViewRepresentable>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.allowsBackForwardNavigationGestures = true
        
        if let url = URL(string: "https://www.loc.gov") {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebViewRepresentable>) {
        link2 = uiView.url!
        return
    }
    
    func goBack(){
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var flagModel: WebViewModel
        
        init(_ viewModel: WebViewModel) {
            self.flagModel = viewModel
        }
        

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            let link = webView.url!.absoluteString + "?fo=json&at=item.mime_type"
            if let url = URL (string: link){
                let html = try? String(contentsOf: url)
                if (html?.contains("jp2") == nil){
                   
                    self.flagModel.isJP2 = false
                }
                else if html!.contains("jp2"){
                    self.flagModel.isJP2 = false
                }
                else{
                    self.flagModel.isJP2 = true
                }
            }
           // link2 = webView.url
//            self.viewModel.didFinishLoading = true
//
//            self.viewModel.link = webView.url!.absoluteString
        }
    }

    func makeCoordinator() -> WebViewRepresentable.Coordinator {
        Coordinator(flagModel)
    }
}
