//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MovieDetailView: View {
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
                    date: viewStore.movie?.releaseDate,
                    score: viewStore.movie?.voteAverage ?? 0,
                    runtime: viewStore.movie?.runtime ?? 0,
                    genres: viewStore.movie?.genres ?? [],
                    tagline: viewStore.movie?.tagline ?? "",
                    overview: viewStore.movie?.overview ?? "",
                    directors: viewStore.directors
                )

                // MARK: - 演员表
                DetailView.Cast(cast: viewStore.movie?.credits?.cast ?? [])
                
                // MARK: - 海报/剧照
                if let images = viewStore.movie?.images {
                    DetailView.Images(
                        selectedImageType: viewStore.binding(\.$selectedImageType),
                        images: images
                    )
                }
                
                // MARK: - 电影系列
                if let collection = viewStore.movie?.belongsToCollection {
                    DetailView.Collection(collection: collection)
                }
                
                // MARK: - 相关推荐
                if let recommendations = viewStore.movie?.recommendations?.results {
                    DetailView.Recommended(recommendations: recommendations)
                }
                
                // MARK: - 电影原产信息
                HStack {
                    DetailView.Original(
                        originalName: viewStore.movie?.originalTitle ?? "",
                        status: viewStore.movie?.status,
                        originalLanguage: viewStore.movie?.originalLanguage ?? "",
                        budget: viewStore.movie?.budget ?? 0,
                        revenue: viewStore.movie?.revenue ?? 0
                    )
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .movie))
            }
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(
            store: .init(
                initialState: .init(media: mockMedias[0]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            )
        )
        .frame(minHeight: 1850)
    }
}
