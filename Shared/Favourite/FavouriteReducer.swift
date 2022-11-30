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
        var selectedMediaType = MediaType.all
        var list: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable {
        case fetchFavouriteList
        case fetchFavouriteListDone(TaskResult<[Favourite]>)

        case media(id: DetailReducer.State.ID, action: DetailReducer.Action)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchFavouriteList:
                return .task {
                    await .fetchFavouriteListDone(TaskResult<[Favourite]> {
                        try persistenceClient.favouriteList()
                    })
                }

            case .fetchFavouriteListDone(.success(let favourites)):
                state.list = .init(uniqueElements: favourites.map {
                    DetailReducer.State(media: .from($0))
                })
                return .none

            case .fetchFavouriteListDone:
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
