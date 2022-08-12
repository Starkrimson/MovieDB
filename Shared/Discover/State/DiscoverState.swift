//
//  DiscoverState.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation
import ComposableArchitecture

struct DiscoverState: Equatable {
    @BindableState var popularIndex: Int = 0
    var popularMovies: IdentifiedArrayOf<Media> = []
    var popularTVShows: IdentifiedArrayOf<Media> = []
    
    var popularList: IdentifiedArrayOf<Media> {
        popularIndex == 0
        ? popularMovies
        : popularTVShows
    }
    
    @BindableState var trendingIndex: Int = 0
    var dailyTrending: IdentifiedArrayOf<Media> = []
    var weeklyTrending: IdentifiedArrayOf<Media> = []
    var trendingList: IdentifiedArrayOf<Media> {
        trendingIndex == 0
        ? dailyTrending
        : weeklyTrending
    }
    
    var error: AppError?
    
    var search = SearchState()
    var isSearchResultListHidden: Bool {
        search.query.isEmpty || search.list.isEmpty
    }
}

struct SearchState: Equatable {
    @BindableState var query: String = ""
    
    var page: Int = 1
    var totalPages: Int = 1
    var list: IdentifiedArrayOf<Media> = []
    
    var isLastPage: Bool { page >= totalPages }
}

enum DiscoverAction: Equatable, BindableAction {
    case binding(BindingAction<DiscoverState>)
    case fetchPopular(MediaType)
    case fetchPopularDone(kind: MediaType, result: TaskResult<[Media]>)
    
    case fetchTrending(mediaType: MediaType = .all, timeWindow: TimeWindow)
    case fetchTrendingDone(
        mediaType: MediaType,
        timeWindow: TimeWindow,
        result: TaskResult<[Media]>)
    
    case search(page: Int = 1)
    case searchResponse(TaskResult<PageResponses<Media>>)
}

struct DiscoverEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var dbClient: MovieDBClient
}

let discoverReducer = Reducer<DiscoverState, DiscoverAction, DiscoverEnvironment> {
    state, action, environment in
    
    switch action {
    case .binding(let action):
        if action.keyPath == \.search.$query, state.search.query.isEmpty {
            state.search = .init()
        }
        return .none
        
    case .fetchPopular(let kind):
        return .task {
            await .fetchPopularDone(kind: kind, result: TaskResult {
                try await environment.dbClient.popular(kind)
            })
        }
        .animation()
        
    case let .fetchPopularDone(kind: .movie, result: .success(results)):
        state.popularMovies = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case let .fetchPopularDone(kind: .tv, result: .success(results)):
        state.popularTVShows = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case .fetchPopularDone(kind: _, result: .failure(let error)):
        if let error = error as? AppError {
            state.error = error
        }
        return .none

    case .fetchPopularDone(kind: _, result: _):
        return .none
        
    case .fetchTrending(mediaType: let mediaType, timeWindow: let timeWindow):
        return .task {
            await .fetchTrendingDone(
                mediaType: mediaType,
                timeWindow: timeWindow,
                result: TaskResult<[Media]> {
                    try await environment.dbClient.trending(mediaType, timeWindow)
                }
            )
        }
        .animation()
        
    case let .fetchTrendingDone(mediaType: _, timeWindow: .day, result: .success(results)):
        state.dailyTrending = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case let .fetchTrendingDone(mediaType: _, timeWindow: .week, result: .success(results)):
        state.weeklyTrending = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case .fetchTrendingDone:
        return .none
        
    case .search(let page):
        enum SearchID: Hashable { }
        
        if state.search.query.isEmpty {
            return .none
        }
        return .task { [query = state.search.query] in
            await .searchResponse(TaskResult<PageResponses<Media>> {
                try await environment.dbClient.search(query, page)
            })
        }
        .animation()
        .cancellable(id: SearchID.self)
            
    case .searchResponse(.success(let value)):
        state.search.page = value.page ?? 1
        state.search.totalPages = value.totalPages ?? 1
        if value.page == 1 {
            state.search.list.removeAll()
        }
        state.search.list.append(contentsOf: value.results ?? [])
        return .none
        
    case .searchResponse(.failure(let error)):
        customDump(error)
        return .none
    }
}
    .binding()
