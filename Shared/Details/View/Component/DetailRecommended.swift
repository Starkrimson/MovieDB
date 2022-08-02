//
//  DetailRecommended.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {

    struct Recommended: View {
        let recommendations: [Media]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("推荐")
                    .font(.title2.weight(.medium))
                    .padding(.horizontal)
                
                // MARK: - 推荐列表
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(recommendations.prefix(10)) { recommend in
                            NavigationLink(destination: .mediaDetail(media: recommend, mediaType: recommend.mediaType)) {
                                VStack {
                                    URLImage(recommend.backdropPath?.imagePath(.face(w: 500, h: 282)))
                                        .frame(width: 250, height: 141)
                                        .cornerRadius(6)
                                    HStack {
                                        Text(recommend.displayName)
                                        Spacer()
                                        Text(recommend.voteAverage.map { "\($0 * 10, specifier: "%.0f")%" } ?? "")
                                    }
                                }
                                .padding(.leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

struct DetailRecommended_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Recommended(recommendations: mockMedias)
    }
}
