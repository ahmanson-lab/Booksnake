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
		
		let bundle = Bundle(identifier: "Assets.xcassets")
		
		let resource = try?  TextureResource.load(contentsOf: image_url)
		//let ao = try? TextureResource.load(named: "ao", in: bundle)
		//let normal = try? TextureResource.load(named: "normal", in: bundle)
		
		var material = PhysicallyBasedMaterial()
		//material.normal = .init(texture: PhysicallyBasedMaterial.Texture.init(normal!))
		//material.ambientOcclusion = .init(texture: PhysicallyBasedMaterial.Texture.init(ao!))
		material.baseColor.texture = PhysicallyBasedMaterial.Texture.init(resource!)
		
        self.components[ModelComponent.self] = ModelComponent(
			mesh: .generatePlane(width: width, depth: height),
			materials: [material]
		)
			self.name = "custom_plane"
		
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
	
}
