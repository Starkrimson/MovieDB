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
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - 电影名称/剧情
                DetailView.Overview(
                    mediaType: .tv,
                    date: viewStore.tv.firstAirDate,
                    score: viewStore.tv.voteAverage,
                    runtime: viewStore.tv.episodeRunTime?.first,
                    genres: viewStore.tv.genres ?? [],
                    tagline: viewStore.tv.tagline,
                    overview: viewStore.tv.overview,
                    directors: viewStore.createdBy,
                    writers: []
                )
                
                // MARK: - 演员表
                if let credits = viewStore.tv.credits, credits.cast?.isEmpty == false {
                    DetailView.Cast(credits: credits)
                }
                
                // MARK: - 当前季
                if let seasons = viewStore.tv.seasons, !seasons.isEmpty {
                    DetailView.Seasons(
                        showName: viewStore.tv.name ?? "",
                        tvID: viewStore.tv.id ?? 0,
                        seasons: seasons
                    )
                }
                
                // MARK: - 海报/剧照
                if let images = viewStore.tv.images {
                    DetailView.Images(
                        images: images,
                        videos: viewStore.tv.videos?.results ?? []
                    )
                }
                
                // MARK: - 相关推荐
                if let recommendations = viewStore.tv.recommendations?.results {
                    DetailView.Recommended(recommendations: recommendations)
                }
                
                // MARK: - 状态信息
                DetailView.Material(detail: .tv(viewStore.tv))
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
                        detail: .tv(.init(mockTVShows[0]))
                    ),
                    reducer: DetailReducer()
                )
                .scope(state: \.detail),
                then: { detailStore in
                    SwitchStore(detailStore) {
                        CaseLet(
                            state: /DetailReducer.DetailState.tv,
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
