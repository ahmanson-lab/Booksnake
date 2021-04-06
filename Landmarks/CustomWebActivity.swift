//
//  CustomUIActivityViewController.swift
//  Landmarks
//
//  Created by Christy Ye on 11/8/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import Foundation
import UIKit

class CustomWebActivity: UIActivityViewController, UIActivityItemSource {
    var _activityTitle: String
    var _activityImage: UIImage?
    var activityItems = [Any]()
    var action: ([Any]) -> Void
    
    init(title: String, image: UIImage?, performAction: @escaping ([Any]) -> Void) {
        _activityTitle = title
        _activityImage = image
        action = performAction
        super.init(activityItems:activityItems, applicationActivities: nil)
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "The pig is in the poke"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "The pig is in the poke 2"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Secret message"
    }

//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        if activityType == .postToTwitter {
//            return "Download #MyAwesomeApp via @twostraws."
//        } else {
//            return "Download MyAwesomeApp from TwoStraws."
//        }
   // }
}
