//
//  ButtonTest.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/23/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    @Binding var progressValue: CGFloat
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .trailing){
                ZStack(alignment:.leading){
                    Color.gray
                    Rectangle()
                        .frame(width: 400, height: 500, alignment: .center)
                    Rectangle()
                        .opacity(0.1)
                    Rectangle()
                        .frame(minWidth: 0, idealWidth: self.getProgressBarWidth(geometry: geometry), maxWidth: self.getProgressBarWidth(geometry: geometry))
                        .opacity(0.5)
                        .background(Color.green)
                        .animation(.default)
                }.frame(height:10)
            }.frame(height:10)
        }
    }
    
    func getProgressBarWidth(geometry: GeometryProxy)-> CGFloat{
        let frame = geometry.frame(in: .global)
        return frame.width * progressValue
    }
    
}
