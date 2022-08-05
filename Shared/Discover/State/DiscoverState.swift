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
    case fetchPopularDone(kind: MediaType, result: Result<[Media], AppError>)
    
    case fetchTrending(mediaType: MediaType = .all, timeWindow: TimeWindow)
    case fetchTrendingDone(
        mediaType: MediaType,
        timeWindow: TimeWindow,
        result: Result<[Media], AppError>)
    
    case search(page: Int = 1)
    case searchDone(result: Result<PageResponses<Media>, AppError>)
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
        return environment.dbClient
            .popular(kind)
            .receive(on: environment.mainQueue)
            .catchToEffect {
                DiscoverAction.fetchPopularDone(kind: kind, result: $0)
            }
            .cancellable(id: kind, cancelInFlight: true)
        
    case let .fetchPopularDone(kind: .movie, result: .success(results)):
        state.popularMovies = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case let .fetchPopularDone(kind: .tv, result: .success(results)):
        state.popularTVShows = .init(uniqueElements: results)
        state.error = nil
        return .none
        
    case .fetchPopularDone(kind: _, result: .failure(let error)):
        state.error = error
        return .none

    case .fetchPopularDone(kind: _, result: _):
        return .none
        
    case .fetchTrending(mediaType: let mediaType, timeWindow: let timeWindow):
        return environment.dbClient
            .trending(mediaType, timeWindow)
            .receive(on: environment.mainQueue)
            .catchToEffect {
                DiscoverAction.fetchTrendingDone(
                    mediaType: mediaType,
                    timeWindow: timeWindow,
                    result: $0
                )
            }
            .cancellable(id: timeWindow)
        
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
        if state.search.query.isEmpty {
            return .none
        }
        return environment.dbClient
            .search(state.search.query, page)
            .receive(on: environment.mainQueue)
            .catchToEffect(DiscoverAction.searchDone(result:))
            .cancellable(id: state.search.query)
        
    case .searchDone(result: .success(let value)):
        state.search.page = value.page ?? 1
        state.search.totalPages = value.totalPages ?? 1
        if value.page == 1 {
            state.search.list.removeAll()
        }
        state.search.list.append(contentsOf: value.results ?? [])
        return .none
        
    case .searchDone(result: .failure(let error)):
        return .none
    }
}
    .binding()
