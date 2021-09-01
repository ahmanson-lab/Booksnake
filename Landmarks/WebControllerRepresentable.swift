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
    @Binding var path: String
    @Binding var isJP2: Bool
	@State var filter: String
    @Binding var hasBackList: Bool
    @Binding var hasForwardList: Bool

	var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    let webView = WKWebView()
    @ObservedObject var viewModel: WebViewModel
	
	var url: URL{
		get{
			return URL(string: search)!
		}
	}
    
    func makeUIView(context: Context) -> WKWebView {
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
			search = temp
            self.webView.load(URLRequest(url: url))
        }
        
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
		self.viewModel.path	 = uiView.url!.absoluteString
    }
	
	func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
		var copy = self
		copy.loadStatusChanged = perform
		return copy
	}
    
    func goBack(){
        webView.goBack()
        self.viewModel.webViewNavigationPublisher.send(.backward)
    }

    func goForward() {
        webView.goForward()
        self.viewModel.webViewNavigationPublisher.send(.forward)
    }
	
	func getPath() -> String {
		return webView.url?.absoluteString ?? ""
	}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable
       // var test: Bool = true
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init( _ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
		override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
			if let key = change?[NSKeyValueChangeKey.newKey]{

				parent.viewModel.path = parent.webView.url!.absoluteString
				//let link = webView.url!.absoluteString
				if parent.viewModel.path.contains(parent.filter) {
					parent.isJP2 = false
				}
				else {
					parent.isJP2 = true
				}
				
				print(parent.viewModel.path)
				//print (key)
			}
		}
		
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            //something
            self.webViewNavigationSubscriber = self.parent.viewModel.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
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
			let link = webView.url!.absoluteString
			
			if link.contains(parent.filter) {
				parent.isJP2 = false
            }
            else {
				parent.isJP2 = true
            }
            
			webView.evaluateJavaScript("document.body.innerText"){ result, error in
				if let resultString = result as? String,
				   resultString.contains("the"){
					self.parent.viewModel.isLoading = false
				}
			}
			
			parent.viewModel.path = webView.url!.absoluteString
			parent.hasBackList = webView.canGoBack
			parent.hasForwardList = webView.canGoForward
        }

		func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
				parent.loadStatusChanged?(false, error)
		}
		
        // This function is essential for intercepting every navigation in the webview
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
			webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
			
            // Suppose you don't want your user to go a restricted site
            if let host = navigationAction.request.url?.host {
                if host == "restricted.com" {
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
			parent.viewModel.path = webView.url!.absoluteString
			parent.hasBackList = webView.canGoBack
			parent.hasForwardList = webView.canGoForward
        }
    }

	func makeCoordinator() -> WebViewRepresentable.Coordinator {
        Coordinator(self)
    }
}
