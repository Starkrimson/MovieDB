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
    
    var loading = false
    
    var movie: Movie?
    var tv: TVShow?
    var person: Person?
    
    var directors: [Media.Crew] = []
    var writers: [Media.Crew] = []
    
    @BindableState var selectedImageType: Media.ImageType = .poster
}

enum DetailAction: Equatable, BindableAction {
    case binding(BindingAction<DetailState>)
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
    case .binding: return .none
        
    case .fetchDetails(mediaType: let mediaType):
        state.loading = true
        return environment.dbClient
            .details(mediaType, state.media.id ?? 0)
            .receive(on: environment.mainQueue)
            .catchToEffect(DetailAction.fetchDetailsDone)
            .cancellable(id: state.media.id ?? 0)
        
    case .fetchDetailsDone(.success(let detail)):
        state.loading = false
        switch detail {
        case .movie(let movie):
            state.movie = movie
            state.directors = movie.credits?.crew?.filter { $0.department == "Directing" } ?? []
            state.writers = movie.credits?.crew?.filter { $0.department == "Writing" } ?? []
        case .tv(let tv):
            state.tv = tv
        case .person(let person):
            state.person = person
        }
        return .none
        
    case .fetchDetailsDone(.failure(let error)):
        state.loading = false
        customDump(error)
        return .none
    }
}
    .binding()
