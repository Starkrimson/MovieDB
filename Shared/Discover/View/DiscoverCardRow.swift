//
//  DiscoverCardRow.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import ComposableArchitecture

extension DiscoverView {
    
    struct CardRow: View {
        let store: Store<IdentifiedArrayOf<DetailReducer.State>, (DetailReducer.State.ID, DetailReducer.Action)>
        
        var body: some View {
            // MARK: - 横向滑动电影/剧集
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEachStore(store) { detailStore in
                        WithViewStore(detailStore, observe: { $0 }) { detailViewStore in
                            NavigationLink {
                                DetailView(store: detailStore)
                            } label: {
                                DiscoverView.CardItem(
                                    posterPath: detailViewStore.media.displayPosterPath,
                                    score: detailViewStore.media.voteAverage,
                                    title: detailViewStore.media.displayName,
                                    date: detailViewStore.media.releaseDate ?? detailViewStore.media.firstAirDate ?? ""
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

extension DiscoverView {
    struct CardItem: View {
        let posterPath: String
        let score: Double?
        let title: String
        let date: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    // MARK: - 海报
                    URLImage(posterPath)
                        .frame(width: 150, height: 225)
                        .cornerRadius(10)
                    
                    // MARK: - 评分圆环
                    if let score {
                        ScoreView(score: score)
                            .offset(y: 17)
                            .padding(.leading)
                    }
                }
                
                // MARK: - 电影/剧集名
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: 150, alignment: .leading)
                    .padding(.leading)
                    .padding(.top, 25)
                
                // MARK: - 发布日期
                Text(date)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.leading)
            }
            .padding(.leading)
        }
    }
}

//struct DiscoverCardRow_Previews: PreviewProvider {
//
//    static var previews: some View {
//        DiscoverView.CardRow(list: .init(uniqueElements: mockMedias))
//    }
//}
