//
//  FavouriteReducer.swift
//  MovieDB
//
//  Created by allie on 29/11/2022.
//

import Foundation
import ComposableArchitecture

struct FavouriteReducer: ReducerProtocol {

    struct State: Equatable {
        @BindingState var selectedMediaType = MediaType.all

        var sort: SortReducer.State = .init()

        var list: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)

        case fetchFavouriteList
        case fetchFavouriteListDone(TaskResult<[CDFavourite]>)

        case sort(SortReducer.Action)

        case media(id: DetailReducer.State.ID, action: DetailReducer.Action)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.sort, action: /Action.sort) {
            SortReducer()
        }
        Reduce { state, action in
            switch action {
            case .binding:
                return .task { .fetchFavouriteList }

            case .fetchFavouriteList:
                return .task { [state = state] in
                    await .fetchFavouriteListDone(TaskResult<[CDFavourite]> {
                        try persistenceClient.favouriteList(
                            state.selectedMediaType,
                            state.sort.sortByKey,
                            state.sort.ascending
                        )
                    })
                }
                .animation()

            case .fetchFavouriteListDone(.success(let favourites)):
                state.list = .init(uniqueElements: favourites.map {
                    DetailReducer.State(media: .from($0))
                })
                return .none

            case .fetchFavouriteListDone(.failure(let error)):
                customDump(error)
                return .none

            case .media:
                return .none

            case .sort(.binding):
                return .task { .fetchFavouriteList }

            case .sort:
                return .none
            }
        }
        .forEach(\.list, action: /Action.media) {
            DetailReducer()
        }
    }
}
