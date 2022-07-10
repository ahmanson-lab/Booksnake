//
//  RealityViewRepresentable.swift
//  Landmarks
//
//  Created by Christy Ye on 11/14/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import SwiftUI
import ARKit

struct RealityViewRepresentable: UIViewControllerRepresentable {
	var width: Float?
	var length: Float?
	var image_url: URL?
	//var hasReturn: Bool = false
	var title: String?

	func makeUIViewController(context: Context) -> UIViewController {
		let picker = RealityViewController()
		picker.width = width
		picker.height = length
		picker.texture_url = image_url
		picker.title_text = title

		return picker
	}
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		//nothing
	}
	
}
