//
//  MovieCollectionState.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import Foundation
import ComposableArchitecture

struct MovieCollectionState: Equatable {
    let belongsTo: BelongsToCollection
    var status: ViewStatus = .loading

    var collection: Movie.Collection?
}

enum MovieCollectionAction: Equatable {
    case fetchCollection
    case fetchCollectionDone(TaskResult<Movie.Collection>)
}

struct MovieCollectionEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let movieCollectionReducer = Reducer<MovieCollectionState, MovieCollectionAction, MovieCollectionEnvironment> {
    state, action, environment in
    
    switch action {
    case .fetchCollection:
        state.status = .loading
        return .task { [id = state.belongsTo.id] in
            await .fetchCollectionDone(TaskResult<Movie.Collection> {
                try await environment.dbClient
                    .collection(id ?? 0)
            })
        }
        .animation()
        
    case .fetchCollectionDone(.success(let value)):
        state.status = .normal
        state.collection = value
        return .none
        
    case .fetchCollectionDone(.failure(let error)):
        state.status = .error(error.localizedDescription)
        return .none
    }
}
