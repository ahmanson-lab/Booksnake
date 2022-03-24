//
//  OnboardingView.swift
//  Landmarks
//
//  Created by Christy Ye on 3/16/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit

struct OnboardingView: View{
	var slide_count:Int = 3
	
	var images:[String] = ["LA1909", "LA1909", "MapOfCalifornia"]
	var test: [String] = ["1Anim"]
	let bundle = Bundle.init(url: URL(fileURLWithPath:"Assets.xcassets").appendingPathComponent("1Anim"))//Bundle(identifier: "Assets.xcassets")
	
	var body: some View {
		ZStack{
			GeometryReader{ proxy in
			TabView{
				ForEach(0..<1){ num in
					
					//VideoPlayer(player: AVPlayer(url: bundle!.url(forResource: "1Anim", withExtension: "mov")!))
					Image(images[num], bundle: bundle)
						//.resizable()
						//.scaledToFit()
						//.tag(num)
				}
				
			}.tabViewStyle(.page)
					.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
			}
			
			
		}
	}
}
