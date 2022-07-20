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
                    score: viewStore.movie?.voteAverage,
                    runtime: viewStore.movie?.runtime,
                    genres: viewStore.movie?.genres ?? [],
                    tagline: viewStore.movie?.tagline,
                    overview: viewStore.movie?.overview,
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
                    if let movie = viewStore.movie {
                        DetailView.Material(detail: .movie(movie))
                            .padding()
                    }
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
        .frame(minHeight: 1950)
    }
}
