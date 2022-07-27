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
    var status: DetailState.Status = .loading

    var collection: Movie.Collection?
}

enum MovieCollectionAction: Equatable {
    case fetchCollection(id: Int)
    case fetchCollectionDone(Result<Movie.Collection, AppError>)
}

struct MovieCollectionEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let movieCollectionReducer = Reducer<MovieCollectionState, MovieCollectionAction, MovieCollectionEnvironment> {
    state, action, environment in
    
    switch action {
    case .fetchCollection(id: let id):
        state.status = .loading
        return environment.dbClient
            .collection(id)
            .receive(on: environment.mainQueue)
            .catchToEffect(MovieCollectionAction.fetchCollectionDone)
            .cancellable(id: id)
        
    case .fetchCollectionDone(.success(let value)):
        state.status = .normal
        state.collection = value
        return .none
        
    case .fetchCollectionDone(.failure(let error)):
        state.status = .error(error)
        return .none
    }
}
