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
	
	required init(image: UIImage) {
		super .init()
		self.components[ModelComponent] = ModelComponent(
			mesh: .generatePlane(width: 1, depth: 1),
			materials: [SimpleMaterial(color: .init(patternImage: image), isMetallic: false)]
			
			)
			self.name = "custom_plane"
		
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
	
}
