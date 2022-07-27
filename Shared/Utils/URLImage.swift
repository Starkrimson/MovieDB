//
//  URLImage.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI
import Kingfisher

struct URLImage: View {
    let url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    init(_ urlString: String?) {
        self.url = URL(string: urlString ?? "")
    }
    
    var body: some View {
        KFImage(url)
            .placeholder {
                Image(systemName: "photo")
                    .font(.largeTitle)
            }
            .resizable()
            .background(Color.secondary)
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(URL(string: "/8bcoRX3hQRHufLPSDREdvr3YMXx.jpg".imagePath(.duotone(w: 1920, h: 600))))
    }
}
