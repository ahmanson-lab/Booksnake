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
