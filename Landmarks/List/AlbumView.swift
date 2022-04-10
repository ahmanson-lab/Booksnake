//
//  AlbumView.swift
//  Landmarks
//
//  Created by Henry Huang on 3/30/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import SwiftUI

extension ImageThumbnailSize {
    var albumSize: CGFloat {
        switch self {
        case .small:
            return 50
        case .medium:
            return 100
        }
    }
}

struct AlbumView: View {
    var imageSize: ImageThumbnailSize
    @Binding var topLeftImageURL: URL?
    @Binding var topRightImageURL: URL?
    @Binding var bottomLeftImageURL: URL?
    @Binding var bottomRightImageURL: URL?

    var body: some View {
        VStack(spacing: 0) {
            let topLeftImage = UIImage.loadThumbnail(at: topLeftImageURL, forSize: imageSize) ?? UIColor.lightGray.image()
            let topRightImage = UIImage.loadThumbnail(at: topRightImageURL, forSize: imageSize) ?? UIColor.lightGray.image()
            let bottomLeftImage = UIImage.loadThumbnail(at: bottomLeftImageURL, forSize: imageSize) ?? UIColor.lightGray.image()
            let bottomRightImage = UIImage.loadThumbnail(at: bottomRightImageURL, forSize: imageSize) ?? UIColor.lightGray.image()

            HStack(spacing: 0) {
                Image(uiImage: topLeftImage)
                    .resizable()
                    .scaleEffect(1.1)   // some image has empty space, so we scale image to make it fill
                    .scaledToFill()
                    .frame(width: imageSize.albumSize, height: imageSize.albumSize, alignment: .center)
                    .clipped()
                    .animation(.none, value: topLeftImage)
                Image(uiImage: topRightImage)
                    .resizable()
                    .scaleEffect(1.1)
                    .scaledToFill()
                    .frame(width: imageSize.albumSize, height: imageSize.albumSize, alignment: .center)
                    .clipped()
                    .animation(.none, value: topRightImage)
            }
            HStack(spacing: 0) {
                Image(uiImage: bottomLeftImage)
                    .resizable()
                    .scaleEffect(1.1)
                    .scaledToFill()
                    .frame(width: imageSize.albumSize, height: imageSize.albumSize, alignment: .center)
                    .clipped()
                    .animation(.none, value: bottomLeftImage)
                Image(uiImage: bottomRightImage)
                    .resizable()
                    .scaleEffect(1.1)
                    .scaledToFill()
                    .frame(width: imageSize.albumSize, height: imageSize.albumSize, alignment: .center)
                    .clipped()
                    .animation(.none, value: bottomRightImage)
            }
        }
        .cornerRadius(5)
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(imageSize: .small,
                  topLeftImageURL: .constant(nil),
                  topRightImageURL: .constant(nil),
                  bottomLeftImageURL: .constant(nil),
                  bottomRightImageURL: .constant(nil))
            .previewLayout(.sizeThatFits)
    }
}
