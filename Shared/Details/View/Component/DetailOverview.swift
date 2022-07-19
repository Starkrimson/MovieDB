//
//  DetailOverview.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Overview: View {
        let displayName: String
        let date: Date?
        let score: Double
        let runtime: Int
        let genres: [Genre]
        let tagline: String
        let overview: String
        let directors: [Media.Crew]
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    VStack {
                        // MARK: - 电影名
                        HStack(alignment: .lastTextBaseline) {
                            Text(displayName)
                                .font(.largeTitle)
                            Text("(\(date?.string("yyyy") ?? ""))")
                                .font(.title3)
                        }
                        
                        // MARK: - 评分
                        HStack {
                            ScoreView(score: score)
                            Text("用户评分")
                                .font(.title3.weight(.medium))
                        }
                        
                        // MARK: - 发布时间
                        Text("\(date?.string("yyyy", "MMMM", "dd") ?? "") · \(runtime)分钟")
                        HStack {
                            ForEach(genres) {
                                Button($0.name ?? "") {
                                    
                                }
                            }
                        }
                    }
                    Spacer()
                }
                
                // MARK: - 简介
                Text(tagline)
                Text("剧情简介")
                    .font(.title2.weight(.medium))
                    .padding(.vertical, 5)
                Text(overview)

                // MARK: - 导演
                ScrollView(.horizontal) {                
                    HStack(alignment: .top) {
                        ForEach(directors) { crew in
                            ProfileView(
                                axis: .horizontal,
                                profilePath: crew.profilePath ?? "",
                                name: crew.name ?? "",
                                job: crew.job ?? ""
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct DetailBasic_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Overview(
            displayName: mockMedias[0].displayName,
            date: mockMovies[0].releaseDate,
            score: mockMovies[0].voteAverage ?? 0,
            runtime: mockMovies[0].runtime ?? 0,
            genres: mockMovies[0].genres ?? [],
            tagline: mockMovies[0].tagline ?? "",
            overview: mockMovies[0].overview ?? "",
            directors: mockMovies[0].credits?.crew?.filter { $0.department == "Directing" } ?? []
        )
    }
}
