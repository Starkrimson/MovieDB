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
}

enum DiscoverAction: Equatable {
    case fetchPopular(MediaType)
    case fetchPopularDone(kind: MediaType, result: Result<[MovieTV], AppError>)
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
        return .none
        
    case let .fetchPopularDone(kind: .tv, result: .success(results)):
        state.popularTVShows = .init(uniqueElements: results)
        return .none
        
    case .fetchPopularDone(kind: _, result: .failure(let error)):
        return .none

    case .fetchPopularDone(kind: _, result: _):
        return .none
    }
}
