//  ARQuickLook.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/22/20.

import ARKit
import UIKit
import RealityKit

class ARView: UIViewController, ARSCNViewDelegate {
    public var texture_image: UIImage?
    public var width: CGFloat?
    public var length: CGFloat?
    public var planeNode: SCNNode?
    
    var shadowNode: SCNNode?
    var target_mat: SCNMaterial?
    var shadow_mat: SCNMaterial?
    var arscene: SCNScene?
    var targetNode: SCNNode?
    var lastPanLocation: SCNVector3?
    var panStartZ: CGFloat = CGFloat(0)
    
    var isFirstTap: Bool = true
    
    let coachingOverlay = ARCoachingOverlayView()
    let instructions = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    var sceneView: ARSCNView{
        return self.view as! ARSCNView
    }
    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking])
        
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
        sceneView.delegate = self
        
        addGestures()
        addCoaching()
        
        sceneView.addSubview(coachingOverlay)

        instructions.frame = CGRect(x: 0, y: UIScreen.main.bounds.height * (2/3) - 10, width: UIScreen.main.bounds.width, height: 200)
        instructions.textAlignment = .center
        instructions.font.withSize(25)
        instructions.text = "Tap and hold to place item"
        instructions.textColor = .white
        sceneView.addSubview(instructions)
        
        //add a target image
        target_mat = SCNMaterial()
        target_mat!.diffuse.contents = UIImage(named: "red")
        
        //create shadow material
        shadow_mat = SCNMaterial()
        shadow_mat?.diffuse.contents = UIColor.init(white: 0, alpha: 1)
        shadow_mat!.transparency = 0.5
        
        //create ar scene
        arscene = SCNScene()
        sceneView.scene = arscene!
        
        let image_plane = SCNPlane(width: length ?? 1, height: width ?? 1)
        planeNode = SCNNode(geometry: image_plane)
        planeNode?.castsShadow = true
        
        let shadow_plane = SCNPlane(width: length ?? 1, height: width ?? 1)
        shadowNode = SCNNode(geometry: shadow_plane)
        

        //adjust object so it's parallel to floor
        let quat = simd_quatf(angle: GLKMathDegreesToRadians(-90), axis: simd_float3(1, 0, 0))
        let rot_matrix = float4x4(quat)
        planeNode?.simdTransform *= rot_matrix
        shadowNode?.simdTransform *= rot_matrix
        
        //add shadow node

    }
    
    //add image as texture to 3d plane
    func addMaterial(image: UIImage, image_plane: SCNPlane) {
        let material = SCNMaterial()
        material.diffuse.contents = image
        image_plane.materials = [material]
    }
    
    //MARK: - Gestures
    
    func addGestures(){
        //let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        let drag = UIPanGestureRecognizer(target: self, action: #selector(dragGesture))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotGesture))
        let press = UILongPressGestureRecognizer(target: self, action: #selector(pressGesture))
        
        //sceneView.addGestureRecognizer(tap)
        sceneView.addGestureRecognizer(press)
        sceneView.addGestureRecognizer(rotate)
       sceneView.addGestureRecognizer(drag)
    }

    @objc func dragGesture(sender: UIPanGestureRecognizer){

        let location = sender.location(in: sceneView)
        switch sender.state {
          case .began:
            //if last Pan loc is null
            if (lastPanLocation == nil) { return}
            
            guard let hitNodeResult = sceneView.hitTest(location, options: nil).first else { return }
            panStartZ = CGFloat(sceneView.projectPoint(lastPanLocation ?? SCNVector3(0,0,0)).z)
            
          //  moveBy(target_loc: SCNVector3( lastPanLocation!.x,lastPanLocation!.y + 0.5,lastPanLocation!.z), node: planeNode!)
            
            // lastPanLocation is new
            lastPanLocation = hitNodeResult.worldCoordinates
          case .changed:

            let worldTouchPosition = sceneView.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
            let movementVector = SCNVector3(
                worldTouchPosition.x - (lastPanLocation?.x ?? 0) ,
                (worldTouchPosition.y - (lastPanLocation?.y ?? 0)),
                0)
            
            planeNode?.isHidden = true
            shadowNode?.localTranslate(by: movementVector)
            self.lastPanLocation = worldTouchPosition
        case .ended:
            planeNode?.isHidden = false
            moveBy(target_loc: shadowNode!.position, node: planeNode!)
            shadowNode?.simdPosition += simd_float3(SCNVector3(0,-0.01,0))
            instructions.isHidden = true
          default:
            break
          }
    }
    
    //first tap to drop shadow , second tap to drop material
    @objc func pressGesture(sender: UILongPressGestureRecognizer){
        let location = sender.location(in: sceneView)
        let hittest = sceneView.hitTest(location, types: .estimatedHorizontalPlane)

        if hittest.isEmpty {
            debugPrint("Cannot find plane")
            return
        }
        else {
            let columns = hittest.first?.worldTransform.columns.3

            //clear scene
            arscene!.rootNode.enumerateChildNodes { (node, stop) in node.removeFromParentNode() }
            if (targetNode != nil){
                targetNode?.isHidden = true
            }
            sceneView.debugOptions = []
            instructions.text = "drag image to move"
            
            //animate plane
            planeNode!.position = SCNVector3(x:columns!.x, y:columns!.y + 0.5, z:columns!.z)
            shadowNode!.position = SCNVector3(x:columns!.x, y:columns!.y - 0.01, z:columns!.z)
            moveBy(target_loc: SCNVector3(x:columns!.x, y:columns!.y, z:columns!.z), node: planeNode!)

            //add materials
            addMaterial(image: texture_image ?? UIImage(), image_plane: planeNode?.geometry as! SCNPlane)
            shadowNode?.geometry?.materials = [shadow_mat!]
            
            //add nodes to scene
            arscene!.rootNode.addChildNode(shadowNode!)
            arscene!.rootNode.addChildNode(planeNode!)
            sceneView.scene = arscene!
            
            lastPanLocation = SCNVector3(x:columns!.x, y:columns!.y, z:columns!.z)
        }
    }
    
    @objc func rotGesture(sender: UIRotationGestureRecognizer){
        if sender.state == .changed {
            let quat = simd_quatf(angle: Float(sender.rotation / 100.0), axis: simd_float3(0, 0, -1))
            let rot_matrix = float4x4(quat)
            planeNode?.simdTransform *= rot_matrix
        }
    }
    
    //MARK: - ANIMATION
    func moveBy(target_loc: SCNVector3, node: SCNNode){
        
        let moveUp = SCNAction.moveBy(x: 0, y: 1, z: 0, duration: 1)
        moveUp.timingMode = .easeInEaseOut;
        
        let target_destination = SCNAction.move(to: target_loc, duration: 3)
        let moveSequence = SCNAction.sequence([target_destination])
        node.runAction(moveSequence)
    }
    
    
    
    //MARK: - Rendering
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
     
        if let anchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: 0.30, height:0.30)
            plane.materials = [target_mat!]
            
            targetNode = SCNNode(geometry: plane)
             
            targetNode?.position = SCNVector3(CGFloat(anchor.center.x), CGFloat(anchor.center.y), CGFloat(anchor.center.z))
            targetNode?.eulerAngles.x = -.pi / 2
             
            node.addChildNode(targetNode!)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

        if let planeGeometry = planeNode?.geometry as? ARSCNPlaneGeometry{
            planeGeometry.update(from: planeAnchor.geometry)
        }
    }
    
    // MARK: - Functions for standard AR view handling
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        
        // Make sure it rescales if the device orientation changes
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
        // Set the Augmented Reality goal
        coachingOverlay.goal = .horizontalPlane
        // Set the ARSession
        coachingOverlay.session = self.sceneView.session

        // Set the delegate for any callbacks
        coachingOverlay.delegate = self
       // debugPrint("is coaching on, ", coachingOverlay.isActive)
  }
    
  // Example callback for the delegate object
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    coachingOverlayView.activatesAutomatically = false
  }
}
