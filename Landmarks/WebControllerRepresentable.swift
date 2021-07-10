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
    var isLoading: Bool = true
}

enum WebViewNavigation {
    case backward, forward
}

struct WebViewRepresentable: UIViewRepresentable {

    @State var search: String
    @State var path: String = ""
    @Binding var isJP2: Bool
    @Binding var hasBackList: Bool
    @Binding var hasForwardList: Bool
    
    let webView = WKWebView()
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: UIViewRepresentableContext<WebViewRepresentable>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.allowsBackForwardNavigationGestures = false
        
        isJP2 = false
        var temp = ""
        
        if (search.contains(" ")){
            temp = search.replacingOccurrences(of: " ", with: "%20")
        }
        
        if let url = URL(string: search) {
            self.webView.load(URLRequest(url: url))
        }
        else if let url = URL(string: temp) {
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
       // var test: Bool = true
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
            }
            
            if link.contains("gov/item"){
                view.isJP2 = false
            }
            else {
                view.isJP2 = true
            }
            
			webView.evaluateJavaScript("document.body.innerText"){ result, error in
				if let resultString = result as? String,
				   resultString.contains("the"){
					self.view.viewModel.isLoading = false
				}
			}
			
            view.viewModel.path = webView.url!.absoluteString
            view.hasBackList = webView.canGoBack
            view.hasForwardList = webView.canGoForward
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
