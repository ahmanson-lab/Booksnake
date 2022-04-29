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

class CustomText: Entity, HasModel, HasCollision, HasAnchoring{
	
	required init(text: String) {
		super .init()
		
		//let bundle = Bundle(identifier: "Assets.xcassets")
		
		let material = SimpleMaterial(color: .green, isMetallic: false)
		
        self.components[ModelComponent.self] = ModelComponent(
			mesh: .generateText(text,
								extrusionDepth: 0.1,
								font: .systemFont(ofSize: 2),
								containerFrame: .zero,
								alignment: .center,
								lineBreakMode: .byTruncatingTail),
			materials: [material]
		)
			self.name = "custom_text"
		
		self.scale = SIMD3<Float>(0.03, 0.03, 0.1)
		//self.anchoring = .init(.world(transform: ))
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
	
}
