//
//  MainListsView.swift
//  Landmarks
//
//  Created by Christy Ye on 2/10/22.
//  Copyright © 2022 Sean Fraga. All rights reserved.
//

import SwiftUI
import UIKit

struct RootListView : View {
	var delegate: AssetRowProtocol?
	
	@State var modalDisplayed = false
	
	var body: some View {
		VStack{
			Button(action: {
				print("something")
				self.modalDisplayed	= true
			}, label: {
				Text("New List")
			})
			.sheet(isPresented: $modalDisplayed){
				NewListView()
			}
			//add created lists here - probs henry's area
			List{}
		}
	}
}

struct ChildListView: View{
	var title: String = "Untitled"
	var subtitle: String = "subtitle"
	var author: String = "Joe Doe"
	var description: String = "something"
	
	let thumbnail: UIImage
	
	//list of content - nav links to ContentView
	
	var body: some View{
		VStack{
			
		}
	}
}

