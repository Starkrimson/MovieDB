//
//  DiscoverReducer.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation
import ComposableArchitecture

struct DiscoverReducer: ReducerProtocol {
    
    struct State: Equatable {
        var backdropPath: String?
        
        @BindableState var popularIndex: Int = 0
        var popularMovies: IdentifiedArrayOf<DetailReducer.State> = []
        var popularTVShows: IdentifiedArrayOf<DetailReducer.State> = []
        
        @BindableState var trendingIndex: Int = 0
        var dailyTrending: IdentifiedArrayOf<DetailReducer.State> = []
        var weeklyTrending: IdentifiedArrayOf<DetailReducer.State> = []

        var error: String?
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        
        case task
        case fetchPopular(MediaType)
        case fetchPopularDone(kind: MediaType, result: TaskResult<[Media]>)
        
        case fetchTrending(mediaType: MediaType = .all, timeWindow: TimeWindow)
        case fetchTrendingDone(
            mediaType: MediaType,
            timeWindow: TimeWindow,
            result: TaskResult<[Media]>)
        
        case popularMovie(id: DetailReducer.State.ID, action: DetailReducer.Action)
        case popularTVShow(id: DetailReducer.State.ID, action: DetailReducer.Action)
        case dailyTrending(id: DetailReducer.State.ID, action: DetailReducer.Action)
        case weeklyTrending(id: DetailReducer.State.ID, action: DetailReducer.Action)
    }
    
    @Dependency(\.dbClient) var dbClient
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .task:
                return .merge(
                    .task { .fetchPopular(.movie) },
                    .task { .fetchPopular(.tv) },
                    .task { .fetchTrending(timeWindow: .day) },
                    .task { .fetchTrending(timeWindow: .week) }
                )
                
            case .fetchPopular(let kind):
                return .task {
                    await .fetchPopularDone(kind: kind, result: TaskResult {
                        try await dbClient.popular(kind, 1).results ?? []
                    })
                }
                .animation()
                
            case let .fetchPopularDone(kind: .movie, result: .success(results)):
                state.popularMovies = .init(uniqueElements: results.map { media in
                    DetailReducer.State(media: media)
                })
                state.error = nil
                return .none
                
            case let .fetchPopularDone(kind: .tv, result: .success(results)):
                state.popularTVShows = .init(uniqueElements: results.map { media in
                    DetailReducer.State(media: media)
                })
                state.error = nil
                return .none
                
            case .fetchPopularDone(kind: _, result: .failure(let error)):
                state.error = error.localizedDescription
                return .none

            case .fetchPopularDone(kind: _, result: _):
                return .none
                
            case .fetchTrending(mediaType: let mediaType, timeWindow: let timeWindow):
                return .task {
                    await .fetchTrendingDone(
                        mediaType: mediaType,
                        timeWindow: timeWindow,
                        result: TaskResult<[Media]> {
                            try await dbClient.trending(mediaType, timeWindow)
                        }
                    )
                }
                .animation()
                
            case let .fetchTrendingDone(mediaType: _, timeWindow: .day, result: .success(results)):
                state.backdropPath = results.randomElement()?.backdropPath
                state.dailyTrending = .init(uniqueElements: results.map { media in
                    DetailReducer.State(media: media)
                })
                state.error = nil
                return .none
                
            case let .fetchTrendingDone(mediaType: _, timeWindow: .week, result: .success(results)):
                state.weeklyTrending = .init(uniqueElements: results.map { media in
                    DetailReducer.State(media: media)
                })
                state.error = nil
                return .none
                
            case .fetchTrendingDone:
                return .none
                
            case .popularMovie:
                return .none
                
            case .popularTVShow:
                return .none
                
            case .dailyTrending:
                return .none
                
            case .weeklyTrending:
                return .none
            }
        }
        .forEach(\.popularMovies, action: /Action.popularMovie) {
            DetailReducer()
        }
        .forEach(\.popularTVShows, action: /Action.popularTVShow) {
            DetailReducer()
        }
        .forEach(\.dailyTrending, action: /Action.dailyTrending) {
            DetailReducer()
        }
        .forEach(\.weeklyTrending, action: /Action.weeklyTrending) {
            DetailReducer()
        }
    }
}
