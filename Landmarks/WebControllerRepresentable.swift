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
import Combine

class WebViewModel: ObservableObject {
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var path: String = ""
}

enum WebViewNavigation {
    case backward, forward
}

struct WebViewRepresentable: UIViewRepresentable {

    @State var search: String
    @State var path: String = ""
    @Binding var isJP2: Bool
    
    let webView = WKWebView()
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: UIViewRepresentableContext<WebViewRepresentable>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.allowsBackForwardNavigationGestures = true
        
        isJP2 = false
        
        if let url = URL(string: search) {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebViewRepresentable>) {
        return
    }
    
    func goBack(){
        webView.goBack()
        self.viewModel.webViewNavigationPublisher.send(.backward)
    }

    func goForward() {
        webView.goForward()
        self.viewModel.webViewNavigationPublisher.send(.forward)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let view: WebViewRepresentable
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init( _ view: WebViewRepresentable) {
            self.view = view
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            //something
            self.webViewNavigationSubscriber = self.view.viewModel.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
                switch navigation {
                    case .backward:
                        if webView.canGoBack {
                            webView.goBack()
                        }
                    case .forward:
                        if webView.canGoForward {
                            webView.goForward()
                        }
                }
            })
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            let link = webView.url!.absoluteString + "?fo=json&at=item.mime_type"
            if let url = URL (string: link){
                let html = try? String(contentsOf: url)
                if (html?.contains("jp2") == nil){
                    view.isJP2 = false
                  
                }
                else if html!.contains("jp2"){
                    view.isJP2 = false
                  
                }
                else{
                    view.isJP2 = true
                  
                }
            }
            
            view.viewModel.path = webView.url!.absoluteString
        }
        
        
        // This function is essential for intercepting every navigation in the webview
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Suppose you don't want your user to go a restricted site
            if let host = navigationAction.request.url?.host {
                if host == "restricted.com" {
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
