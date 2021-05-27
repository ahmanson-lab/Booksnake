//
//  URLInputView.swift
//  Landmarks
//
//  Created by Christy Ye on 4/17/21.
//  Created by Christy Ye,  © University of Southern California
//

import SwiftUI

struct URLInputView: View {
    
    @State var fieldValue: String = ""
    @Binding var presentedAsModal: Bool
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    @State private var isError: Bool = false
    
    @ObservedObject var model = WebViewModel()
    
    @State var hasJP2: Bool = true
    @State private var active: Bool = false
    
    var delegate: AssetRowProtocol?
    var body: some View {

            ZStack(alignment: .top, content: {
                Color.init(.systemGray5).edgesIgnoringSafeArea(.all)

                VStack{
                    Text("Library of Congress")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10.0)
                        
                    Text("Search hundres of thousands of historical manuscripts, maps, newpapers, and more.")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.all, 10.0)
                    
                    TextField("Search titles, authors, places, and more", text: $fieldValue, onEditingChanged: {_ in }, onCommit: {
                        active  = true
                    })
                    .textContentType(.oneTimeCode)
                    .keyboardType(.webSearch)
                    .padding(.horizontal, 10.0)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.gray)
                    .font(.body)
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
                        
                    Text("Search results are limited to Library of Congress materials with an IIIF manifest, which Booksnake uses to add items")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .bottom, .trailing], 10.0)
                    
                    NavigationLink(
                        destination: FullWebView(delegate: delegate, presentedAsModal:$presentedAsModal, hasJP2: $hasJP2, webview: WebViewRepresentable(search: "https://www.loc.gov/search/?q=" + fieldValue + "&fa=mime-type:image/jp2", isJP2: $hasJP2, viewModel: model )),  isActive: $active,
                        label: {
                            Text("Search")
                        })
                        .padding(.all, 10.0)
                        .navigationBarTitle(active ? "Search" : "", displayMode: .inline)
                        
                    Spacer()
                    
                }
            })
    }
}
