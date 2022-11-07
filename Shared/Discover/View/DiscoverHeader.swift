//
//  DiscoverHeader.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI

extension DiscoverView {
    struct Header: View {
        var backdropPath: String? = ""
        
        var body: some View {
            ZStack {
                // MARK: - 背景图
                GeometryReader { proxy in
                    URLImage(backdropPath?.imagePath(.duotone(w: 1920, h: 600)))
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: 240)
                        .clipped()
                }
                
                // MARK: - 渐变遮罩
                LinearGradient(
                    colors: [
                        Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0.8),
                        Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                VStack(alignment: .leading) {
                    Text("WELCOME TITLE".localized)
                        .font(.title)
                    
                    Text("WELCOME CONTENT".localized)
                        .font(.title2)
                }
                .foregroundColor(.white)
                .fontWeight(.medium)
                .padding()
            }
            .frame(height: 240)
        }
    }
}

struct DiscoverHeader_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView.Header(backdropPath: "/8bcoRX3hQRHufLPSDREdvr3YMXx.jpg")
    }
}
