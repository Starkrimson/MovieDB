//
//  TVDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct TVDetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                // MARK: - 背景图和海报
                DetailView.Header(
                    backdropPath: viewStore.media.backdropPath,
                    posterPath: viewStore.media.posterPath
                )
                
                // MARK: - 电影名称/剧情
                DetailView.Overview(
                    displayName: viewStore.media.displayName,
                    date: viewStore.tv?.firstAirDate,
                    score: viewStore.tv?.voteAverage,
                    runtime: viewStore.tv?.episodeRunTime?.first,
                    genres: viewStore.tv?.genres ?? [],
                    tagline: viewStore.tv?.tagline,
                    overview: viewStore.tv?.overview,
                    directors: viewStore.directors,
                    writers: viewStore.writers
                )
                
                if viewStore.loading {
                    ProgressView()
                } else {
                    // MARK: - 演员表
                    if let cast = viewStore.movie?.credits?.cast, !cast.isEmpty {
                        DetailView.Cast(cast: cast)
                    }
                    
                    // MARK: - 当前季
                    if let lastSeason = viewStore.tv?.seasons?.last {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("当前季")
                                    .font(.title2.weight(.medium))
                                Text("\(lastSeason.name ?? "")")
                                Spacer()
                            }
                            Text("\(lastSeason.airDate?.string("yyyy") ?? "") | \(lastSeason.episodeCount ?? 0)集")
                                .padding(.top, 3)
                            lastSeason.overview.map { overview in
                                Text(overview)
                                    .padding(.top, 6)
                            }
                        }
                        .padding()
                    }

                    // MARK: - 海报/剧照
                    if let images = viewStore.tv?.images {
                        DetailView.Images(
                            selectedImageType: viewStore.binding(\.$selectedImageType),
                            images: images
                        )
                    }
                    
                    // MARK: - 相关推荐
                    if let recommendations = viewStore.tv?.recommendations?.results {
                        DetailView.Recommended(recommendations: recommendations)
                    }

                    // MARK: - 状态信息
                    viewStore.tv.map { tv in
                        DetailView.Material(detail: .tv(tv))
                            .padding()
                    }
                }
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .tv))
            }
        }
    }
}

struct TVDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TVDetailView(
            store: .init(
                initialState: .init(media: mockMedias[1]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            )
        )
        .frame(minHeight: 1800)
    }
}
