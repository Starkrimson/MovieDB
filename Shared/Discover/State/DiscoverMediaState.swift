//
//  DiscoverMediaState.swift
//  MovieDB
//
//  Created by allie on 1/8/2022.
//

import Foundation
import ComposableArchitecture

struct DiscoverMediaState: Equatable {
    let mediaType: MediaType
    let name: String
    var withKeywords: [Int] = []
    var withGenres: [Int] = []

    var page: Int = 1
    var totalPages: Int = 1
    var list: [Media] = []
    
    var status: DetailState.Status = .loading
    
    var isLastPage: Bool { page >= totalPages }
}

enum DiscoverMediaAction: Equatable {
    case fetchMedia(loadMore: Bool = false)
    case fetchMediaDone(loadMore: Bool, result: Result<PageResponses<Media>, AppError>)
}

struct DiscoverMediaEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let discoverMediaReducer = Reducer<
    DiscoverMediaState, DiscoverMediaAction, DiscoverMediaEnvironment
> {
    state, action, environment in
    switch action {
    case .fetchMedia(let loadMore):
        state.status = .loading
        return environment.dbClient
            .discover(state.mediaType, [
                .page(loadMore ? state.page + 1 : 1),
                .keywords(state.withKeywords),
                    .genres(state.withGenres)
            ])
            .receive(on: environment.mainQueue)
            .catchToEffect {
                DiscoverMediaAction.fetchMediaDone(loadMore: loadMore, result: $0)
            }
            .cancellable(id: state.page)
        
    case .fetchMediaDone(let loadMore, result: .success(let value)):
        state.status = .normal
        state.page = value.page ?? 1
        state.totalPages = value.totalPages ?? 1
        let list = value.results ?? []
        state.list = loadMore ? state.list + list : list
        return .none
        
    case .fetchMediaDone(_, result: .failure(let error)):
        state.status = .error(error)
        return .none
    }
}
