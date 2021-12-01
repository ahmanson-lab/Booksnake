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
		guard let touchInView = sender?.location(in: self.realityView) else { return }
		guard let query = realityView.makeRaycastQuery(from: touchInView, allowing: .estimatedPlane, alignment: .horizontal) else {return}
		
		let coord = self.realityView.unproject(touchInView, ontoPlane: matrix_identity_float4x4)
		guard let hitResult = realityView.session.raycast(query).first	else {return}
		
		//plane
		let plane = CustomPlane(image_url: texture_url ?? "Hollywood.jpg")
		plane.position = coord!
		realityView.scene.anchors.append(plane)
		
		realityView.installGestures([.all], for: plane)
		plane.generateCollisionShapes(recursive: true)
		print("nothign ", hitResult)
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




