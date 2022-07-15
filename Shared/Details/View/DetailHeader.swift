//
//  DetailHeader.swift
//  MovieDB
//
//  Created by allie on 15/7/2022.
//

import SwiftUI
import Kingfisher

extension DetailView {
    
    struct Header: View {
        let backdropPath: String?
        let posterPath: String?
        
        var body: some View {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        // MARK: - 背景图
                        KFImage(URL(
                            string: backdropPath?.imagePath(.w1000_and_h450_multi_faces) ?? "")
                        )
                        .resizable()
                        .frame(width: proxy.size.width)
                        
                        // MARK: - 渐变
                        LinearGradient(
                            colors: [
                                Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0.8),
                                Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )

                        // MARK: - 海报
                        KFImage(URL(string: posterPath?.imagePath() ?? ""))
                            .resizable()
                            .cornerRadius(6)
                            .aspectRatio(440/660, contentMode: .fit)
                            .padding(.vertical, 20)
                            .padding(.leading, 20)
                    }
                }
                .aspectRatio(1000/450, contentMode: .fill)
        }
    }
}
struct DetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Header(
            backdropPath: mockMedias[0].backdropPath,
            posterPath: mockMedias[0].posterPath
        )
    }
}
