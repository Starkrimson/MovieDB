//
//  EpisodeReducer.swift
//  MovieDB
//
//  Created by allie on 17/11/2022.
//

import Foundation
import ComposableArchitecture

struct EpisodeReducer: ReducerProtocol {

    struct State: Equatable {
        let tvID: Int
        var episode: Episode

        var status: ViewStatus = .normal
    }

    enum Action: Equatable {
        case fetchEpisode
        case fetchEpisodeDone(TaskResult<Episode>)
    }

    @Dependency(\.dbClient) var dbClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchEpisode:
                state.status = .loading
                return .task { [tvID = state.tvID, episode = state.episode] in
                    await .fetchEpisodeDone(TaskResult<Episode> {
                        try await dbClient.episode(tvID, episode.seasonNumber ?? 0, episode.episodeNumber ?? 0)
                    })
                }
            case .fetchEpisodeDone(.success(let episode)):
                state.status = .normal
                state.episode = episode
                return .none

            case .fetchEpisodeDone(.failure(let error)):
                state.status = .error(error.localizedDescription)
                return.none
            }
        }
    }
}
