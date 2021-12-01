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
	
	required init(image_url: String) {
		super .init()
		
		let resource = try? TextureResource.load(named: image_url)
		
		var material = PhysicallyBasedMaterial()
		//material.baseColor = UIColor.white
		material.baseColor.texture = PhysicallyBasedMaterial.Texture.init(resource!)
		
		self.components[ModelComponent] = ModelComponent(
			mesh: .generatePlane(width: 1, depth: 1),
			materials: [material]
			)
			self.name = "custom_plane"
		
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
	
}
