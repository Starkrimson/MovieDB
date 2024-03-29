//
//  DetailOverview.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {

    struct Overview: View {
        let mediaType: MediaType
        let date: Date?
        let score: Double?
        let runtime: Int?
        let genres: [Genre]
        let tagline: String?
        let overview: String?
        let directors: [Media.Crew]
        let writers: [Media.Crew]

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    VStack {
                        // MARK: - 评分
                        score.map { score in
                            ScoreView(score: score)
                        }

                        // MARK: - 发布时间
                        HStack(spacing: 0) {
                            Text("\(date?.string("yyyy", "MMMM", "dd") ?? "")")
                            runtime.map { runtime in
                                Text(" · \(runtime) \("MINUTES".localized)")
                            }
                        }
                        .padding(6)

                        // MARK: - 类型
                        HStack {
                            ForEach(genres) { item in
                                NavigationLink {
                                    DiscoverMediaView(store: .init(
                                        initialState: .init(
                                            mediaType: mediaType,
                                            name: item.name ?? "",
                                            filters: [.genres([item.id ?? 0])]
                                        ),
                                        reducer: DiscoverMediaReducer()
                                    ))
                                } label: {
                                    Text(item.name ?? "")
                                }
                            }
                        }
                    }
                    Spacer()
                }

                // MARK: - 简介
                Text(tagline ?? "")
                    .font(.body.italic())
                    .padding([.horizontal, .top])
                overview.map { overview in
                    Text(overview)
                        .padding(.horizontal)
                        .header("OVERVIEW".localized)
                }

                // MARK: - 导演/编剧
                ForEach([directors, writers].filter { !$0.isEmpty }, id: \.self) { list in
                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(list) { crew in
                                NavigationLink {
                                    DetailView(store: .init(
                                        initialState: .init(media: .from(crew)),
                                        reducer: DetailReducer()
                                    ))
                                } label: {
                                    ProfileView(
                                        axis: .horizontal,
                                        profilePath: crew.profilePath ?? "",
                                        name: crew.name ?? "",
                                        job: crew.job?.localized ?? ""
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct DetailBasic_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Overview(
            mediaType: .movie,
            date: mockMovies[0].releaseDate,
            score: mockMovies[0].voteAverage,
            runtime: mockMovies[0].runtime,
            genres: mockMovies[0].genres ?? [],
            tagline: mockMovies[0].tagline,
            overview: mockMovies[0].overview,
            directors: mockMovies[0].credits?.crew?.filter { $0.department == "Directing" } ?? [],
            writers: mockMovies[0].credits?.crew?.filter { $0.department == "Writing" } ?? []
        )
    }
}
#endif
