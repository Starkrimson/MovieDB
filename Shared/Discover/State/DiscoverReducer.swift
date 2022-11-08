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
        var popularMovies: IdentifiedArrayOf<Media> = []
        var popularTVShows: IdentifiedArrayOf<Media> = []
        
        var popularList: IdentifiedArrayOf<Media> {
            popularIndex == 0
            ? popularMovies
            : popularTVShows
        }
        
        @BindableState var trendingIndex: Int = 0
        var dailyTrending: IdentifiedArrayOf<Media> = []
        var weeklyTrending: IdentifiedArrayOf<Media> = []
        var trendingList: IdentifiedArrayOf<Media> {
            trendingIndex == 0
            ? dailyTrending
            : weeklyTrending
        }
        
        var error: AppError?
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
                        try await dbClient.popular(kind)
                    })
                }
                .animation()
                
            case let .fetchPopularDone(kind: .movie, result: .success(results)):
                state.popularMovies = .init(uniqueElements: results)
                state.error = nil
                return .none
                
            case let .fetchPopularDone(kind: .tv, result: .success(results)):
                state.popularTVShows = .init(uniqueElements: results)
                state.error = nil
                return .none
                
            case .fetchPopularDone(kind: _, result: .failure(let error)):
                state.error = error as? AppError
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
                state.dailyTrending = .init(uniqueElements: results)
                state.error = nil
                return .none
                
            case let .fetchTrendingDone(mediaType: _, timeWindow: .week, result: .success(results)):
                state.weeklyTrending = .init(uniqueElements: results)
                state.error = nil
                return .none
                
            case .fetchTrendingDone:
                return .none
            }
        }
    }
}
