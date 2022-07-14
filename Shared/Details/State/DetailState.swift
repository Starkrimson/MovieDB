//
//  DetailState.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation

import Foundation
import ComposableArchitecture

struct DetailState: Equatable {
    let media: Media
    
    var movie: Movie?
}

enum DetailAction: Equatable {
    case fetchDetails(mediaType: MediaType)
    case fetchDetailsDone(Result<DetailModel, AppError>)
}

struct DetailEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let detailReducer = Reducer<DetailState, DetailAction, DetailEnvironment> {
    state, action, environment in
    
    switch action {
    case .fetchDetails(mediaType: let mediaType):
        return environment.dbClient
            .details(mediaType, state.media.id ?? 0)
            .receive(on: environment.mainQueue)
            .catchToEffect(DetailAction.fetchDetailsDone)
            .cancellable(id: state.media.id ?? 0)
        
    case .fetchDetailsDone(.success(let detail)):
        switch detail {
        case .movie(let movie):
            state.movie = movie
        }
        return .none
        
    case .fetchDetailsDone(.failure(let error)):
        customDump(error)
        return .none
    }
}
