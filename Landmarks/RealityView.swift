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
	
	//var textureImage: UIImage?
	var texture_url: URL?
	var width: Float?
	var height: Float?

    var realityView = ARView(frame: .zero)
	
	override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(realityView)
        realityView.translatesAutoresizingMaskIntoConstraints = false
        realityView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        realityView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        realityView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        realityView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		self.addCoaching()
		addGestures()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection  = [.horizontal]
        realityView.session.run(config, options: [.removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        realityView.session.pause()
    }

    deinit {
        print("RealityView Deinit")
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
		
		let plane = CustomPlane(image_url: texture_url ?? URL(fileURLWithPath: "Hollywood.jpg"), width: width ?? 1.0, height: height ?? 1.0)
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




