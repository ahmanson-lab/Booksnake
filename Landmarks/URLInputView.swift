//
//  URLInputView.swift
//  Landmarks
//
//  Created by Christy Ye on 4/17/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import SwiftUI

struct URLInputView: View {
    
    @State var fieldValue: String = ""
    @Binding var presentedAsModal: Bool
    @Binding var progressPercent: CGFloat
    @State private var isAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .first
    @State private var isError: Bool = false
    
    @State var hasJP2: Bool = true
    
    //CustomWebView(path: "http://www.loc.gov", delegate: delegate!, presentedAsModal: $presentedAsModal)
    
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
                    
                    TextField("Search titles, authors, places, and more", text: $fieldValue.onChange(findReturn))
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
                        .padding(.horizontal, 10.0)
                }
            })
    }
    
    
    func findReturn(_ tag: String) {
        if (tag.contains("\n")){
//            CustomWebView(path: tag.remove(at: tag.index(before: tag.endIndex - 1)), delegate: delegate!, presentedAsModal: $presentedAsModal)
        }
        
    }
}
