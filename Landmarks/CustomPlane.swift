//
//  CustomPlane.swift
//  Landmarks
//
//  Created by Christy Ye on 11/8/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation
import RealityKit
import UIKit

class CustomPlane: Entity, HasModel, HasCollision, HasAnchoring{
	
	required init(image_url: URL, width: Float, height: Float) {
		super .init()
		
		let resource = try? TextureResource.load(contentsOf: image_url) //TextureResource.load(named: image_url.absoluteString)
		
		var material = PhysicallyBasedMaterial()
		//material.baseColor = UIColor.white
		material.baseColor.texture = PhysicallyBasedMaterial.Texture.init(resource!)
		
		self.components[ModelComponent] = ModelComponent(
			mesh: .generatePlane(width: width, depth: height),
			materials: [material]
			)
			self.name = "custom_plane"
		
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
	
}
