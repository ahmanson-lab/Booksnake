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
	var image: UIImage?
	var width: CGFloat?
	var length: CGFloat?
	var image_url: String?
	
	typealias UIViewControllerType = UIViewController
	
	func makeUIViewController(context: Context) -> UIViewController {
		let picker = RealityView()
		picker.textureImage = image
		picker.width = width
		picker.height = length
		picker.texture_url = image_url
		return picker
	}
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		//nothing
	}
	
}
