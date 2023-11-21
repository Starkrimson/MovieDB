//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct MovieDetailView: View {
    let store: Store<MovieState, DetailReducer.Action>

    var body: some View {
        WithViewStore(store) { $0 } content: { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - 电影名称/剧情
                DetailView.Overview(
                    mediaType: .movie,
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
                if viewStore.movie.images != nil {
                    DetailView.Images(store: .init(
                        initialState: viewStore.imageGridState,
                        reducer: { ImageGridReducer() }
                    ))
                }

                // MARK: - 电影系列
                if let collection = viewStore.movie.belongsToCollection {
                    DetailView.Collection(collection: collection)
                        .padding(.top)
                }

                // MARK: - 相关推荐
                if let recommendations = viewStore.movie.recommendations?.results, !recommendations.isEmpty {
                    DetailView.Recommended(recommendations: recommendations)
                }

                // MARK: - 电影原产信息
                DetailView.Material(detail: .movie(viewStore.movie))
                    .padding()
            }
        }
    }
}

#if DEBUG
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IfLetStore(
            StoreOf<DetailReducer>(
                initialState: .init(
                    media: mockMedias[0],
                    detail: .movie(.init(mockMovies[0]))
                ),
                reducer: { DetailReducer() }
            )
            .scope(state: \.detail, action: { $0 }),
            then: { detailStore in
                SwitchStore(detailStore) { _ in
                    CaseLet(
                        state: /DetailReducer.DetailState.movie,
                        then: MovieDetailView.init
                    )
                }
            }
        )
        .frame(minHeight: 1650)
    }
}
#endif
