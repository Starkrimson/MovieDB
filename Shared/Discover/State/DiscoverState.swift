//
//  DiscoverState.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation
import ComposableArchitecture

struct DiscoverState: Equatable {
    var popularMovies: IdentifiedArrayOf<MovieTV> = []
    var popularTVShows: IdentifiedArrayOf<MovieTV> = []
    
    var dailyTrending: IdentifiedArrayOf<MovieTV> = []
    var weeklyTrending: IdentifiedArrayOf<MovieTV> = []
    
    var error: AppError?
}

enum DiscoverAction: Equatable {
    case fetchPopular(MediaType)
    case fetchPopularDone(kind: MediaType, result: Result<[MovieTV], AppError>)
    
    case fetchTrending(mediaType: MediaType = .all, timeWindow: TimeWindow)
    case fetchTrendingDone(
        mediaType: MediaType,
        timeWindow: TimeWindow,
        result: Result<[MovieTV], AppError>)
}

struct DiscoverEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let discoverReducer = Reducer<DiscoverState, DiscoverAction, DiscoverEnvironment> {
    state, action, environment in
    
    switch action {
    case .fetchPopular(let kind):
        return environment.dbClient
            .popular(kind)
            .receive(on: environment.mainQueue)
            .catchToEffect {
                DiscoverAction.fetchPopularDone(kind: kind, result: $0)
            }
            .cancellable(id: kind, cancelInFlight: true)
        
    case let .fetchPopularDone(kind: .movie, result: .success(results)):
        state.popularMovies = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case let .fetchPopularDone(kind: .tv, result: .success(results)):
        state.popularTVShows = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case .fetchPopularDone(kind: _, result: .failure(let error)):
        state.error = error
        return .none

    case .fetchPopularDone(kind: _, result: _):
        return .none
        
    case .fetchTrending(mediaType: let mediaType, timeWindow: let timeWindow):
        return environment.dbClient
            .trending(mediaType, timeWindow)
            .receive(on: environment.mainQueue)
            .catchToEffect {
                DiscoverAction.fetchTrendingDone(
                    mediaType: mediaType,
                    timeWindow: timeWindow,
                    result: $0
                )
            }
            .cancellable(id: timeWindow)
        
    case let .fetchTrendingDone(mediaType: _, timeWindow: .day, result: .success(results)):
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
