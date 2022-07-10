//
//  Extensions.swift
//  Landmarks
//
//  Created by Henry Huang on 2/27/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import Foundation
import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum DecoderError: Error {
    case missingManagedObjectContext
}

extension String {
    var urlEscaped: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var urlDecoded: String {
        self.removingPercentEncoding!
    }
}

func goLibrary() {
	if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene  {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		let contentView = AssetRow().environment(\.managedObjectContext, context)
		windowScene.windows.first?.rootViewController =  UIHostingController(rootView: contentView)
		windowScene.windows.first?.makeKeyAndVisible()
	}
}

struct CustomNavigationView<Content: View>: View {
	let build: Content
	
	init(@ViewBuilder build: @escaping () -> Content) {
		self.build = build()
	}
	
	var body: some View {
		ZStack{
			build
			VStack{
				HStack{
					Button(action: { goLibrary() }, label: { Text("Library") })
						.padding(.all, 10.0)
						.font(.title)
					Spacer()
				}
				.frame(alignment: .leading)
				Spacer()
			}
			.frame(alignment: .leading)
		}
		.frame(alignment: .topLeading)
	}
}

extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    func previous() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let previous = all.index(before: idx)
        return all[previous < all.startIndex ? all.index(before: all.endIndex) : previous]
    }

    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
}


// Idea for pop to root: https://stackoverflow.com/questions/57334455/swiftui-how-to-pop-to-root-view
struct NavigationUtil {
  static func popToRootView() {
    findNavigationController(viewController: UIApplication.shared.keyWindow?.rootViewController)?
      .popToRootViewController(animated: true)
  }

  static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
    guard let viewController = viewController else {
      return nil
    }

    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }

    for childViewController in viewController.children {
      return findNavigationController(viewController: childViewController)
    }

    return nil
  }
}
