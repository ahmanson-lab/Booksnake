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




