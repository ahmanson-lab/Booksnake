//
//  CreateListView.swift
//  Landmarks
//
//  Created by Christy Ye on 2/10/22.
//  Copyright © 2022 Sean Fraga. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct NewListView: View{
	@Environment(\.presentationMode) var presentation
	var body: some View{
		NavigationView{
			
			Text("View open")
				.navigationTitle(Text("Add Items to New List"))
				.toolbar{
				ToolbarItem(placement: .navigation){
					Button("Cancel"){
						print("back")
						self.presentation.wrappedValue.dismiss()
					}.foregroundColor(.red)
				}
					ToolbarItem(placement: .navigationBarTrailing){
					Button("Done"){ }
				}
				}
		}
		
	}
}
