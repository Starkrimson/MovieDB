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
        @BindableState var selectedMediaType = MediaType.all
        @BindableState var sortByKeyPath: PartialKeyPath<Favourite> = \Favourite.dateAdded
        @BindableState var ascending: Bool = false
        let keyPaths = [
            \Favourite.dateAdded,
            \Favourite.releaseDate,
            \Favourite.title
        ]

        var list: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)

        case fetchFavouriteList
        case fetchFavouriteListDone(TaskResult<[Favourite]>)

        case media(id: DetailReducer.State.ID, action: DetailReducer.Action)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .task { .fetchFavouriteList }

            case .fetchFavouriteList:
                return .task { [state = state] in
                    await .fetchFavouriteListDone(TaskResult<[Favourite]> {
                        try persistenceClient.favouriteList(
                            state.selectedMediaType,
                            (state.sortByKeyPath, state.ascending)
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
            }
        }
        .forEach(\.list, action: /Action.media) {
            DetailReducer()
        }
    }
}
