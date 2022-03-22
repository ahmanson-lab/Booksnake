//
//  RectangularImage.swift
//  Landmarks
//
//  Created by Sean Fraga on 7/21/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import SwiftUI

struct RectangularImage: View {
    
    var image: UIImage?
    
    init(image: UIImage) {
        self.image = image
    }
    
    var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .shadow(radius: 15)
    }
}
