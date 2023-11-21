//
//  SeasonState.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SeasonReducer {

    struct State: Equatable, Hashable {
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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSeason:
                state.status = .loading
                return .run { [state] send in
                    await send(.fetchSeasonDone(TaskResult<Season> {
                        try await dbClient.season(state.tvID, state.seasonNumber)
                    }))
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
