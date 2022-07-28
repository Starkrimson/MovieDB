//
//  SeasonState.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import Foundation
import ComposableArchitecture

struct SeasonState: Equatable {
    let tvID: Int
    let seasonNumber: Int
    let showName: String
    
    var status: DetailState.Status = .loading
    var season: Season?
    
    var episodes: [Episode] { season?.episodes ?? [] }
}

enum SeasonAction: Equatable {
    case fetchSeason
    case fetchSeasonDone(Result<Season, AppError>)
}

struct SeasonEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let seasonReducer = Reducer<SeasonState, SeasonAction, SeasonEnvironment> {
    state, action, environment in
    
    switch action {
    case .fetchSeason:
        state.status = .loading
        return environment.dbClient
            .season(state.tvID, state.seasonNumber)
            .receive(on: environment.mainQueue)
            .catchToEffect(SeasonAction.fetchSeasonDone)
        
    case .fetchSeasonDone(.success(let season)):
        state.status = .normal
        state.season = season
        return .none
        
    case .fetchSeasonDone(.failure(let error)):
        state.status = .error(error)
        return .none
    }
}
