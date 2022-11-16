//
//  ImageBrowser.swift
//  MovieDB
//
//  Created by allie on 16/11/2022.
//

import SwiftUI

struct ImageBrowser: View {
    var image: Media.Image

    @Environment(\.openURL) private var openURL
    
    var originURL: URL {
        guard let path = image.filePath?.imagePath(.original),
              let url = URL(string: path) else {
            return URL(filePath: "/null")
        }
        return url
    }
    
    var ratio: Double {
        guard let width = image.width, let height = image.height else {
            return 1
        }
        return Double(width) / Double(height)
    }
    
    @ViewBuilder
    var urlImage: URLImage {
        URLImage(image.filePath?.imagePath(.original))
    }
    
    var body: some View {
        urlImage
            .aspectRatio(ratio, contentMode: .fit)
            .toolbar {
                Button {
                    openURL(originURL)
                } label: {
                    Label("VIEW ON WEB".localized, systemImage: "link.circle")
                }
                ShareLink(item: urlImage, preview: .init(image.filePath ?? "", image: urlImage))
            }
    }
}

struct ImageBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ImageBrowser(
            image: mockMovies[0].images!.backdrops![0]
        )
    }
}
