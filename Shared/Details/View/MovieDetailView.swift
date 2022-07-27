//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct MovieDetailView: View {
    let store: Store<MovieState, DetailAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                // MARK: - 电影名称/剧情
                DetailView.Overview(
                    date: viewStore.movie.releaseDate,
                    score: viewStore.movie.voteAverage,
                    runtime: viewStore.movie.runtime,
                    genres: viewStore.movie.genres ?? [],
                    tagline: viewStore.movie.tagline,
                    overview: viewStore.movie.overview,
                    directors: viewStore.directors,
                    writers: viewStore.writers
                )
                
                // MARK: - 演员表
                if let credits = viewStore.movie.credits, credits.cast?.isEmpty == false {
                    DetailView.Cast(credits: credits)
                }
                
                // MARK: - 海报/剧照
                if let images = viewStore.movie.images {
                    DetailView.Images(
                        selectedImageType: viewStore.binding(
                            get: \.selectedImageType,
                            send: {
                                .selectImageType(mediaType: .movie, imageType: $0)
                            }
                        ),
                        images: images
                    )
                }
                
                // MARK: - 电影系列
                if let collection = viewStore.movie.belongsToCollection {
                    DetailView.Collection(collection: collection)
                }
                
                // MARK: - 相关推荐
                if let recommendations = viewStore.movie.recommendations?.results {
                    DetailView.Recommended(recommendations: recommendations)
                }
                
                // MARK: - 电影原产信息
                DetailView.Material(detail: .movie(viewStore.movie))
                    .padding()
            }
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IfLetStore(
            Store<DetailState, DetailAction>(
                initialState: .init(
                    media: mockMedias[0],
                    movieState: .init(mockMovies[0])
                ),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            ).scope(state: \.movieState),
            then: MovieDetailView.init
        )
        .frame(minHeight: 1650)
    }
}
