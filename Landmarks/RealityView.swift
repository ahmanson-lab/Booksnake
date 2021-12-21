//
//  RealityView.swift
//  Landmarks
//
//  Created by Christy Ye on 11/8/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation
import RealityKit
import UIKit
import ARKit

class RealityView: UIViewController, ARSessionDelegate  {
	
	var textureImage: UIImage?
	var texture_url: String?
	var width: CGFloat?
	var height: CGFloat?
	
	
	var realityView: ARView {
			return self.view as! ARView
	}
	
	override func loadView() {
		self.view = ARView(frame: .zero)
		self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		self.addCoaching()
		addGestures()
		
		let config = ARWorldTrackingConfiguration()
		config.planeDetection  = [.horizontal]
		realityView.session.run(config, options: [.removeExistingAnchors])
	}
		
	
	func addGestures(){
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
		realityView.addGestureRecognizer(tap)
	}
	
	
	@objc func tapGesture( _ sender: UITapGestureRecognizer? = nil){
		
		guard let query = realityView.makeRaycastQuery(from: realityView.center, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
		
		guard let hitResult = realityView.session.raycast(query).first	else {return}
		
		// set a transform to an existing entity
		let transform = Transform(matrix: hitResult.worldTransform)
		
		let plane = CustomPlane(image_url: texture_url ?? "Hollywood.jpg")
		plane.transform = transform
		realityView.scene.anchors.append(plane)
		
		realityView.installGestures([.all], for: plane)
		plane.generateCollisionShapes(recursive: true)
	}
}

extension RealityView: ARCoachingOverlayViewDelegate {
	func addCoaching(){
		
		let coachingOverlay = ARCoachingOverlayView()
		coachingOverlay.delegate = self
		coachingOverlay.session = self.realityView.session
		coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		coachingOverlay.goal = .anyPlane
		self.realityView.addSubview(coachingOverlay)
	}
	
}




