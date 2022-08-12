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
    var list: IdentifiedArrayOf<Media> = []
    
    var status: DetailState.Status = .loading
    
    var isLastPage: Bool { page >= totalPages }
}

enum DiscoverMediaAction: Equatable {
    case fetchMedia(loadMore: Bool = false)
    case fetchMediaDone(loadMore: Bool, result: TaskResult<PageResponses<Media>>)
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
        return .task { [state] in
            await .fetchMediaDone(loadMore: loadMore, result: TaskResult<PageResponses<Media>> {
                try await environment.dbClient
                    .discover(state.mediaType, [
                        .page(loadMore ? state.page + 1 : 1),
                        .keywords(state.withKeywords),
                        .genres(state.withGenres)
                    ])
            })
        }
        .animation()
        
    case .fetchMediaDone(let loadMore, result: .success(let value)):
        state.status = .normal
        state.page = value.page ?? 1
        state.totalPages = value.totalPages ?? 1
        let list = value.results ?? []
        if !loadMore {
            state.list.removeAll()
        }
        state.list.append(contentsOf: list)
        return .none
        
    case .fetchMediaDone(_, result: .failure(let error)):
        state.status = .error(error as! AppError)
        return .none
    }
}
