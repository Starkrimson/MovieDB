//
//  MovieCollectionState.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MovieCollectionReducer {

    struct State: Equatable, Hashable {
        let belongsTo: BelongsToCollection
        var status: ViewStatus = .loading

        var collection: Movie.Collection?

        var movies: IdentifiedArrayOf<DetailReducer.State> = []
    }

    enum Action: Equatable {
        case fetchCollection
        case fetchCollectionDone(TaskResult<Movie.Collection>)

        case movies(IdentifiedActionOf<DetailReducer>)
    }

    @Dependency(\.dbClient) var dbClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchCollection:
                state.status = .loading
                return .run { [id = state.belongsTo.id] send in
                    await send(.fetchCollectionDone(TaskResult<Movie.Collection> {
                        try await dbClient
                            .collection(id ?? 0)
                    }))
                }
                .animation()

            case .fetchCollectionDone(.success(let value)):
                state.status = .normal
                state.collection = value

                state.movies = .init(uniqueElements: value.parts?.map {
                    DetailReducer.State(media: $0)
                } ?? [])

                return .none

            case .fetchCollectionDone(.failure(let error)):
                state.status = .error(error.localizedDescription)
                return .none

            case .movies:
                return .none
            }
        }
        .forEach(\.movies, action: \.movies) {
            DetailReducer()
        }
    }
}
