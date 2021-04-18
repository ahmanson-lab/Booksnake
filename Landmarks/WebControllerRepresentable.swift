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
    @Published var link: String
    @Published var didFinishLoading: Bool = false
    @Published var didChange: Bool = false

    init (link: String) {
        self.link = link
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<WebViewRepresentable>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: viewModel.link) {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebViewRepresentable>) {
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            let link = webView.url!.absoluteString + "?fo=json&at=item.mime_type"
            if let url = URL (string: link){
                let html = try? String(contentsOf: url)
                if (html?.contains("jp2") == nil){
                    self.viewModel.didChange = false
                }
                else if html!.contains("jp2"){
                    self.viewModel.didChange = false
                }
                else{
                    self.viewModel.didChange = true
                }
            }
            
            self.viewModel.didFinishLoading = true
            self.viewModel.link = webView.url!.absoluteString
        }
    }

    func makeCoordinator() -> WebViewRepresentable.Coordinator {
        Coordinator(viewModel)
    }
}
