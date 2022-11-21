//
//  SeasonState.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import Foundation
import ComposableArchitecture

struct SeasonReducer: ReducerProtocol {
    
    struct State: Equatable {
        let tvID: Int
        let seasonNumber: Int
        let showName: String
        
        var status: ViewStatus = .loading
        var season: Season?
        
        var episodes: [Episode] { season?.episodes ?? [] }
    }
    
    enum Action: Equatable {
        case fetchSeason
        case fetchSeasonDone(TaskResult<Season>)
    }
    
    @Dependency(\.dbClient) var dbClient
        
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSeason:
                state.status = .loading
                return .task { [state] in
                    await .fetchSeasonDone(TaskResult<Season> {
                        try await dbClient.season(state.tvID, state.seasonNumber)
                    })
                }
                
            case .fetchSeasonDone(.success(let season)):
                state.status = .normal
                state.season = season
                return .none
                
            case .fetchSeasonDone(.failure(let error)):
                state.status = .error(error.localizedDescription)
                return .none
            }
        }
    }
}
