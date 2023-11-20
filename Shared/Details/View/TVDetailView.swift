//
//  TVDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct TVDetailView: View {
    let store: Store<TVState, DetailReducer.Action>

    var body: some View {
        WithViewStore(store) { $0 } content: { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - 电影名称/剧情
                DetailView.Overview(
                    mediaType: .tvShow,
                    date: viewStore.tvShow.firstAirDate,
                    score: viewStore.tvShow.voteAverage,
                    runtime: viewStore.tvShow.episodeRunTime?.first,
                    genres: viewStore.tvShow.genres ?? [],
                    tagline: viewStore.tvShow.tagline,
                    overview: viewStore.tvShow.overview,
                    directors: viewStore.createdBy,
                    writers: []
                )

                // MARK: - 演员表
                if let credits = viewStore.tvShow.credits, credits.cast?.isEmpty == false {
                    DetailView.Cast(credits: credits)
                }

                // MARK: - 当前季
                if let seasons = viewStore.tvShow.seasons, !seasons.isEmpty {
                    DetailView.Seasons(
                        showName: viewStore.tvShow.name ?? "",
                        tvID: viewStore.tvShow.id ?? 0,
                        seasons: seasons
                    )
                }

                // MARK: - 海报/剧照
                if viewStore.tvShow.images != nil {
                    DetailView.Images(store: .init(
                        initialState: viewStore.imageGridState,
                        reducer: { ImageGridReducer() }
                    ))
                }

                // MARK: - 相关推荐
                if let recommendations = viewStore.tvShow.recommendations?.results {
                    DetailView.Recommended(recommendations: recommendations)
                }

                // MARK: - 状态信息
                DetailView.Material(detail: .tvShow(viewStore.tvShow))
                    .padding()
            }
        }
    }
}

#if DEBUG
struct TVDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IfLetStore(
                StoreOf<DetailReducer>(
                    initialState: .init(
                        media: mockMedias[1],
                        detail: .tvShow(.init(mockTVShows[0]))
                    ),
                    reducer: { DetailReducer() }
                )
                .scope(state: \.detail, action: { $0 }),
                then: { detailStore in
                    SwitchStore(detailStore) { _ in
                        CaseLet(
                            state: /DetailReducer.DetailState.tvShow,
                            then: TVDetailView.init
                        )
                    }
                }
            )
            .frame(minHeight: 1550)
        }
    }
}
#endif
