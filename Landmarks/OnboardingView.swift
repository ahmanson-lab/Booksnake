//
//  OnboardingView.swift
//  Landmarks
//
//  Created by Christy Ye on 3/16/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingView: View{
	var slide_count:Int = 3
	
	var images:[String] = ["1", "LA1909", "MapOfCalifornia"]
	
	var body: some View {
		ZStack{
			GeometryReader{ proxy in
			TabView{
				ForEach(0..<slide_count){ num in
					Image(images[num])
						.resizable()
						.scaledToFit()
						.tag(num)
					
				}
				
			}.tabViewStyle(.page)
					.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
			}
			
			
		}
	}
}
