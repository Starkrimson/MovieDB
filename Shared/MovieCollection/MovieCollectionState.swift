//
//  MovieCollectionState.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import Foundation

import Foundation
import ComposableArchitecture

struct MovieCollectionState: Equatable {
    let belongsTo: BelongsToCollection
    var status: DetailState.Status = .loading

    var collection: Movie.Collection?
}

enum MovieCollectionAction: Equatable {
    case fetchCollection
    case fetchCollectionDone(Result<Movie.Collection, AppError>)
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
        return environment.dbClient
            .collection(state.belongsTo.id ?? 0)
            .receive(on: environment.mainQueue)
            .catchToEffect(MovieCollectionAction.fetchCollectionDone)
            .cancellable(id: state.belongsTo)
        
    case .fetchCollectionDone(.success(let value)):
        state.status = .normal
        state.collection = value
        return .none
        
    case .fetchCollectionDone(.failure(let error)):
        state.status = .error(error)
        return .none
    }
}
