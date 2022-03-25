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

struct OnboardingView: View {
	var delegate: AssetRowProtocol?
	@State private var showingPreview = false
	@State private var isLast = false
	
	var videos:[[String]] = [["0_onboarding", "0"],["1_Aim",""], ["2_Tap", ""], ["3_Explore",""], ["4", "4"]]
	var image_title: [String] = ["Welcome to Booksnake!", "1. Aim Your Device", "2. Tap to Place", "3. Explore Your Item","Aim. Tap. Explore."]
	var description: [[String]] = [["Booksnake lets you explore digitized archival materials as if they were physically present in the real world.", "Select an item, then tap \"View in AR.\" \n\nSwipe left for a quick orientation."], ["\nHold your device horizontally and aim it a table or wall within ten feet of you. For best results, turn the room lights on."], ["\nAfter aiming, tap the middle of your device’s screen to place your digitized item on a flat surface in the real world."],["\nMove your device to explore. Instead of pinching to zoom, try moving closer, farther, over, or around your item."], [""]]
	
	var body: some View {
		//GeometryReader{ proxy in
		VStack{		
			TabView{
				ForEach(0..<videos.count ){ num in
					if (videos[num][1] == "0"){
						VStack{
							Text(image_title[num]).font(.title).fontWeight(.bold).frame(alignment: .center)
							Text(description[0][0])
									.font(.subheadline)
									.fontWeight(.light)
									.frame(alignment: .center)
							Image(uiImage: UIImage(named: videos[num][0]) ?? UIImage())
								.resizable()
								.scaledToFit()
							Text(description[0][1])
									.font(.subheadline)
									.fontWeight(.light)
									.frame(alignment: .center)
							Spacer()
						}
					}
					else if (videos[num][1] == "4"){
						VStack{
							Text(image_title[num]).font(.title).fontWeight(.bold).frame(alignment: .center)
							
							VStack{
								HStack{
									Image(systemName: "camera.metering.multispot").resizable().foregroundColor(.blue).frame(width: 60, height: 40)
									Text(description[1][0])
								}
								HStack{
									Image(systemName: "hand.tap").resizable().foregroundColor(.blue).frame(width: 60, height: 60)
									Text(description[2][0])
								}
								HStack{
									Image(systemName: "person.fill.and.arrow.left.and.arrow.right").resizable().foregroundColor(.blue).frame(width: 60, height: 40)
									Text(description[3][0])
								}
							}
							Spacer()
							NavigationLink(
								destination: LazyView(RealityViewRepresentable(width: 1, length: 1, image_url: Bundle.main.url(forResource: "LA1909", withExtension: "jpg"), title: "Los Angeles, 1909"))
									.navigationBarTitle("")
									.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center),
								isActive: $showingPreview) {
									ZStack(){
										Color.init(.systemBlue)
											.cornerRadius(10)
										Text("View in AR")
											.foregroundColor(.white)
											.font(.system(size: 18, weight: .medium, design: .default))
									}
									.frame(height: 50.0)
									.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
							}
							Text("Tap to try with an example item")
							Spacer()
						}
					}
					else{
						VStack{
							VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: videos[num][0], withExtension: "mov")!))
							Text(image_title[num]).font(.title).fontWeight(.bold).frame(alignment: .leading)
							Text (description[num][0]).font(.subheadline).fontWeight(.light).frame(alignment: .leading)
							Spacer()
						}
					}
				}
			}.tabViewStyle(.page)
					Button("Skip"){
						delegate?.closeOnboardingView()
					}
			Spacer()
			//}.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
		}
	}
}

struct MiniOnboardingView: View{
	var description: [[String]] = [["Booksnake lets you explore digitized archival materials as if they were physically present in the real world.", "Select an item, then tap \"View in AR.\" \n\nSwipe left for a quick orientation."], ["\nHold your device horizontally and aim it a table or wall within ten feet of you. For best results, turn the room lights on."], ["\nAfter aiming, tap the middle of your device’s screen to place your digitized item on a flat surface in the real world."],["\nMove your device to explore. Instead of pinching to zoom, try moving closer, farther, over, or around your item."], [""]]
	var body: some View {
		VStack{
			Text("How to Use Booksnake").font(.title).fontWeight(.bold).frame(alignment: .center)
			
			VStack{
				HStack{
					Image(systemName: "camera.metering.multispot").resizable().foregroundColor(.blue).frame(width: 60, height: 40)
					Text(description[1][0])
				}
				HStack{
					Image(systemName: "hand.tap").resizable().foregroundColor(.blue).frame(width: 60, height: 60)
					Text(description[2][0])
				}
				HStack{
					Image(systemName: "person.fill.and.arrow.left.and.arrow.right").resizable().foregroundColor(.blue).frame(width: 60, height: 40)
					Text(description[3][0])
				}
			}
			Spacer()
			Text("Tap to try with an example item")
			Spacer()
		}
	}
}
