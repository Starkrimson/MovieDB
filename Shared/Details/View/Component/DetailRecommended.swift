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
            // MARK: - 推荐列表
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEach(recommendations.prefix(10)) { recommend in
                        NavigationLink {
                            DetailView(store: .init(
                                initialState: .init(media: recommend),
                                reducer: DetailReducer()
                            ))
                        } label: {
                            VStack {
                                URLImage(recommend.backdropPath?.imagePath(.face(w: 500, h: 282)))
                                    .frame(width: 250, height: 141)
                                    .cornerRadius(6)
                                HStack {
                                    Text(recommend.displayName)
                                        .lineLimit(1)
                                    Spacer()
                                    recommend.voteAverage
                                        .map { ($0, true) }
                                        .map(ScoreView.init)
                                }
                                .frame(width: 250)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .header("RECOMMENDATIONS".localized)
        }
    }
}

#if DEBUG
struct DetailRecommended_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Recommended(recommendations: mockMedias)
    }
}
#endif
