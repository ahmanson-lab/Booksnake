//
//  URLInputView.swift
//  Landmarks
//
//  Created by Christy Ye on 4/17/21.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import SwiftUI

struct URLInputView: View {
    @Binding var presentedAsModal: Bool
    @Binding var label: String
    
    @State var fieldValue: String = ""
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    @State private var isError: Bool = false
    @State var isLoading: Bool = true
    
    @ObservedObject var model = WebViewModel()
    
    @State var hasJP2: Bool = true
    @State var hasBackList: Bool = false
    @State var hasForwardList: Bool = false
    @State private var active: Bool = false
    
    var delegate: AssetRowProtocol?
    var body: some View {

            ZStack(alignment: .top, content: {
                Color.init(.systemGray6)

                VStack{
                    Text("Library of Congress")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)
                        
                    Text("Search hundreds of thousands of historical manuscripts, maps, newpapers, and more.")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                    
                    TextField("Search titles, authors, places...", text: $fieldValue, onEditingChanged: {_ in }, onCommit: {
                        active  = true
                    })
                    .textContentType(.oneTimeCode)
                    .keyboardType(.webSearch)
                    .padding(.horizontal, 20.0)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.gray)
                    .font(.body)
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
                        
                    Text("Search results are limited to Library of Congress materials with an IIIF manifest, which Booksnake uses to add items.")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .bottom, .trailing], 20.0)
                    
                    NavigationLink(
						destination: FullWebView(delegate: delegate, presentedAsModal:$presentedAsModal, hasJP2: $hasJP2, label: $label, webview: WebViewRepresentable(search: "https://www.loc.gov/search/?q=" + fieldValue + "&fa=mime-type:image/jp2", isJP2: $hasJP2, hasBackList: $hasBackList, hasForwardList: $hasForwardList, viewModel: model )),  isActive: $active,
                        label: {
                            ZStack(){
                                Color.init(.systemBlue)
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 50, alignment: .center)
                                    .cornerRadius(10)
                                Text("Search")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium, design: .default))
                            }
                        })
                        .padding(.all, 10.0)
                        .navigationBarTitle(active ? "Search" : "", displayMode: .inline)
                        
                    Spacer()
                    
                }
            })
    }
}
