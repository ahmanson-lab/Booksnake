//
//  OnboardingView.swift
//  Landmarks
//
//  Created by Christy Ye on 3/16/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
 
struct OnboardingView: View {
	var delegate: AssetRowProtocol?
	@State private var showingPreview = false
	@State private var isLast = false
	@State private var buttonName = "Skip"

	var preloadContents: [String] = ["onboarding_page1", "1_Aim", "2_Tap", "3_Explore",""]
	var image_title: [String] = ["Welcome to Booksnake!", "1. Aim Your Device", "2. Tap to Place", "3. Explore Your Item","Aim. Tap. Explore."]
	var description: [String] = ["Booksnake lets you explore digitized archival materials as if they were physically present in the real world.", "\nHold your device horizontally and aim it a table or wall within ten feet of you. For best results, turn the room lights on.", "\nAfter aiming, tap the middle of your device’s screen to place your digitized item on a flat surface in the real world.","\nMove your device to explore. Instead of pinching to zoom, try moving closer, farther, over, or around your item.", ""]
	var icon_list: [String] = ["", "camera.metering.multispot", "hand.tap", "person.fill.and.arrow.left.and.arrow.right"]
	
	//@ViewBuilder
    var body: some View {
        VStack{
            TabView{
                ForEach(Array(zip(preloadContents.indices, preloadContents)), id: \.0) { index, contentName in
                    if (index == 0) {
                        VStack{
                            Spacer()
                            Text(image_title[index])
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(alignment: .center)
                            Text( "\n" + description[0] + "\n")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .frame(alignment: .center)
                            Image(uiImage: UIImage(named: contentName) ?? UIImage())
                                .resizable()
                                .scaledToFit()
                            Text("\n" + "Select an item, then tap \"View in AR.\" \n\nSwipe left for a quick orientation.")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .frame(alignment: .center)
                            Spacer()
                        }
                        .frame(alignment: .center)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 60, trailing: 20))
                        .onAppear(perform: {buttonName = "Skip"})
                    }
                    else if (index == 4) {
						VStack {
                            Spacer()
                            Text(image_title[index])
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(alignment: .center)
								
							List {
								ForEach(1..<description.count - 1){ num in
									HStack {
										Image(systemName: icon_list[num])
											.resizable()
											.scaledToFit()
											.foregroundColor(.blue)
											.frame(width: 80.0, height: 80.0, alignment: .leading)
										Spacer()
											.frame(width: 20)
										Text(description[num])
											.minimumScaleFactor(0.1)
									}
									.listRowSeparator(.hidden)
								}
							}

                            Spacer()
                            Button(action: {
								// Set onboardingView Showed when user is finished
								UserDefaults.standard.set(true, forKey: "isOnboardingShowed")
                                delegate?.closeOnboardingView()
                                goRealityView()
                            }, label: {
                                ZStack{
                                    Color.init(.systemBlue)
                                        .cornerRadius(10)
                                    Text("View in AR")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .medium, design: .default))
                                }
                                .frame(height: 50.0)
                                .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                            })

                            Text("Tap to try with an example item")
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 60, trailing: 20))
						.frame(alignment: .leading)
                        .onAppear(perform: {buttonName = "Go to Library"})
                    }
                    else {
                        VStack{
                            Spacer()
                            AnimatedImage(url: Bundle.main.url(forResource: contentName, withExtension: "gif")!)
                                .playbackMode(.normal)
                                .resizable()
                                .scaledToFit()
                            Text(image_title[index])
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(alignment: .leading)
                            Text (description[index])
                                .font(.subheadline)
                                .fontWeight(.light)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 60, trailing: 20))
                        .onAppear(perform: { buttonName = "Skip" })
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            Button(self.buttonName){
				// Set onboardingView Showed when user is finished
				UserDefaults.standard.set(true, forKey: "isOnboardingShowed")
                delegate?.closeOnboardingView()
                goLibrary()
            }
            Spacer()
        }
	}
	
	func goRealityView() {
		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene  {
			windowScene.windows.first?.rootViewController = UIHostingController(rootView: CustomNavigationView {
                RealityViewRepresentable(width: 1, length: 1, image_url: Bundle.main.url(forResource: "LA1909", withExtension: "jpg"), title: "Los Angeles, 1909")
            })
			windowScene.windows.first?.makeKeyAndVisible()
		}
	}
}

struct MiniOnboardingView: View {
	@Environment(\.presentationMode) var presentationMode
	var delegate: AssetRowProtocol?
	
	var description: [String] = ["Hold your device horizontally and aim it a table or wall within ten feet of you. For best results, turn the room lights on.", "After aiming, tap the middle of your device’s screen to place your digitized item on a flat surface in the real world.","Move your device to explore. Instead of pinching to zoom, try moving closer, farther, over, or around your item."]
	var icon_list: [String] = ["camera.metering.multispot", "hand.tap", "person.fill.and.arrow.left.and.arrow.right"]
	var titles: [String] = ["Aim", "Tap", "Explore"]
	
	var body: some View {
		NavigationView{
			VStack{
				Text("How to Use Booksnake")
					.font(.title)
					.fontWeight(.bold)
					.padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
				List {
					ForEach(0..<description.count){ num in
						HStack{
							Image(systemName: icon_list[num])
								.resizable()
								.scaledToFit()
								.foregroundColor(.blue)
								.frame(width: 50, height: 50)
							Spacer()
								.frame(width: 20)
							VStack{
								HStack{
									Text(titles[num])
										.font(.title)
										.fontWeight(.bold)
									Spacer()
								}
								.padding(EdgeInsets(top: 10, leading: 5, bottom: 1, trailing: 10))
								Text(description[num])
									.minimumScaleFactor(0.1)
									.multilineTextAlignment(.leading)
									.padding(EdgeInsets(top: 10, leading: 1, bottom: 1, trailing: 10))
							}
						}
						.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
						.listRowSeparator(.hidden)
					}
				}
			}
			.toolbar(content: {
				ToolbarItem(placement: .navigationBarLeading){
					Button("Done"){
						delegate?.closeOnboardingView()
						presentationMode.wrappedValue.dismiss()
					}
				}
			})
		}
	}
}
