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
        var selectedMediaType = MediaType.all

        var sort: SortReducer.State = .init()
        var list: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable {
        case fetchWatchlist
        case fetchWatchlistDone(TaskResult<[CDWatch]>)

        case media(id: DetailReducer.State.ID, action: DetailReducer.Action)

        case sort(SortReducer.Action)
        case selectMediaType(MediaType)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.sort, action: /Action.sort) {
            SortReducer()
        }
        Reduce { state, action in
            switch action {
            case .fetchWatchlist:
                return .task { [state = state] in
                    await .fetchWatchlistDone(TaskResult<[CDWatch]> {
                        try persistenceClient.watchlist(
                            state.selectedMediaType,
                            state.sort.sortByKey,
                            state.sort.ascending
                        )
                    })
                }
                .animation()

            case .fetchWatchlistDone(.success(let list)):
                state.list = .init(uniqueElements: list.map { .init(media: .from($0)) })
                return .none

            case .fetchWatchlistDone(.failure(let error)):
                customDump(error)
                return .none

            case .media:
                return .none

            case .sort(.binding):
                return .task { .fetchWatchlist }

            case .sort:
                return .none

            case .selectMediaType(let type):
                state.selectedMediaType = type
                return .task { .fetchWatchlist }
            }
        }
        .forEach(\.list, action: /Action.media) {
            DetailReducer()
        }
    }
}
