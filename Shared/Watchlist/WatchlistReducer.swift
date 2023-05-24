//
//  WatchlistReducer.swift
//  MovieDB
//
//  Created by allie on 24/5/2023.
//

import Foundation
import ComposableArchitecture

struct WatchlistReducer: ReducerProtocol {

    struct State: Equatable {
        var list: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable {
        case fetchWatchlist
        case fetchWatchlistDone(TaskResult<[CDWatch]>)

        case media(id: DetailReducer.State.ID, action: DetailReducer.Action)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchWatchlist:
                return .task {
                    await .fetchWatchlistDone(TaskResult<[CDWatch]> {
                        try persistenceClient.watchlist()
                    })
                }

            case .fetchWatchlistDone(.success(let list)):
                state.list = .init(uniqueElements: list.map { .init(media: .from($0)) })
                return .none

            case .fetchWatchlistDone(.failure(let error)):
                customDump(error)
                return .none
            case .media:
                return .none
            }
        }
        .forEach(\.list, action: /Action.media) {
            DetailReducer()
        }
    }
}
