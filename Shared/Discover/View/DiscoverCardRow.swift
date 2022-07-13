//
//  DiscoverCardRow.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

extension DiscoverView {
    
    struct CardRow: View {
        var list: IdentifiedArrayOf<Media> = []
    
        var body: some View {
            // MARK: - 横向滑动电影/剧集
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(list) { item in
                        DiscoverView.CardItem(
                            posterPath: "https://www.themoviedb.org/t/p/w440_and_h660_face/\(item.posterPath ?? item.profilePath ?? "")",
                            score: item.voteAverage,
                            title: item.title ?? item.name ?? "",
                            date: item.releaseDate ?? item.firstAirDate ?? ""
                        )
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
                    KFImage(URL(string: posterPath))
                        .resizable()
                        .frame(width: 150, height: 225)
                        .cornerRadius(10)
                    
                    // MARK: - 评分圆环
                    if let score {
                        ZStack {
                            Text("\(score * 10, specifier: "%.0f")%")
                                .font(.caption)
                                .frame(width: 34, height: 34)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(17)
                            
                            Circle()
                                .trim(from: 1 - score / 10, to: 1)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 30/255.0, green: 213/255.0, blue: 169/255.0),
                                            Color(red: 1/255.0, green: 180/255.0, blue: 228/255.0),
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    style: .init(
                                        lineWidth: 3, lineCap: .round, lineJoin: .round
                                    )
                                )
                                .rotationEffect(.degrees(90))
                                .rotation3DEffect(.degrees(180), axis: (1,0,0))
                                .frame(width: 34, height: 34)
                        }
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
            .padding(.horizontal)
        }
    }
}

struct DiscoverCardRow_Previews: PreviewProvider {

    static var previews: some View {
        DiscoverView.CardRow(list: .init(uniqueElements: mockMedias))
    }
}
