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
	var texture_url: URL?
	var width: Float?
	var height: Float?
	var title_text: String?
	var dir_light: DirectionalLight = DirectionalLight()
	var firstTap: Bool = true
	var realityView = ARView(frame: .zero)
	
	override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(realityView)
        realityView.translatesAutoresizingMaskIntoConstraints = false
        realityView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        realityView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        realityView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        realityView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

		dir_light.light.color = .white
		dir_light.light.intensity = 20000
		dir_light.light.isRealWorldProxy = true
		dir_light.shadow?.maximumDistance = 10.0
		dir_light.shadow?.depthBias = 5.0
		dir_light.orientation = simd_quatf(angle: -.pi/1.5, axis: [0,1,0])
		
		self.addCoaching()
		
		addGestures()
		
		let target = try! TargetScene.load_TargetScene() //MARK: Consider using ModelEntity with .clearcoat
		realityView.scene.addAnchor(target)
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let config = ARWorldTrackingConfiguration()
		config.planeDetection  = [.horizontal, .vertical]
		realityView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        realityView.session.pause()
    }
	
	func addGestures(){
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longGesture(_:)))
		realityView.addGestureRecognizer(tap)
		realityView.addGestureRecognizer(longPress)
	}
	
	@objc func longGesture(_ sender: UILongPressGestureRecognizer? = nil){
//		guard let hittest = realityView.entity(at: sender?.location(in: realityView) ?? realityView.center)else { return}
			
		//MARK: 3D text removed
//			if hittest.name == "custom_plane" {
//				var textModelComponent = CustomText(text: title_text ?? "something")
//				textModelComponent.position = SIMD3<Float>(0, 0.06, 0)
//				hittest.addChild(textModelComponent)
//			}
	}

	@objc func tapGesture( _ sender: UITapGestureRecognizer? = nil){
		guard let query = realityView.makeRaycastQuery(from: sender?.location(in: realityView) ?? realityView.center, allowing: .existingPlaneInfinite, alignment: .horizontal) else {
			return
		}
		
		guard let hitResult = realityView.session.raycast(query).first else { return }
		
		// set a transform to an existing entity
		let transform = Transform(matrix: hitResult.worldTransform)
		
		if (firstTap){
			let plane = CustomPlane(image_url: texture_url ?? URL(fileURLWithPath: "Hollywood.jpg"), width: width ?? 1.0, height: height ?? 1.0)
			plane.transform = transform
			realityView.scene.anchors.removeAll()
			realityView.scene.anchors.append(plane)
			
			realityView.installGestures([.all], for: plane)
			
			plane.generateCollisionShapes(recursive: true)
			firstTap = false
			
			let lightAnchor = AnchorEntity(world: [0,0,-3])
			lightAnchor.addChild(dir_light)
			
			realityView.scene.anchors.append(lightAnchor)
		}
		else {
			if let plane = realityView.scene.findEntity(named: "custom_plane"){
				plane.transform = transform
			}
		}
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




