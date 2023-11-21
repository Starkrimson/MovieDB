//
//  WatchlistReducer.swift
//  MovieDB
//
//  Created by allie on 24/5/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WatchlistReducer {

    struct State: Equatable {
        var selectedMediaType = MediaType.all

        var sort: SortReducer.State = .init()
        var list: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable {
        case fetchWatchlist
        case fetchWatchlistDone(TaskResult<[CDWatch]>)

        case media(IdentifiedActionOf<DetailReducer>)

        case sort(SortReducer.Action)
        case selectMediaType(MediaType)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerOf<Self> {
        Scope(state: \.sort, action: /Action.sort) {
            SortReducer()
        }
        Reduce { state, action in
            switch action {
            case .fetchWatchlist:
                return .run { [state = state] send in
                    await send(.fetchWatchlistDone(TaskResult<[CDWatch]> {
                        try persistenceClient.watchlist(
                            state.selectedMediaType,
                            state.sort.sortByKey,
                            state.sort.ascending
                        )
                    }))
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
                return .send(.fetchWatchlist)

            case .sort:
                return .none

            case .selectMediaType(let type):
                state.selectedMediaType = type
                return .send(.fetchWatchlist)
            }
        }
        .forEach(\.list, action: \.media) {
            DetailReducer()
        }
    }
}
