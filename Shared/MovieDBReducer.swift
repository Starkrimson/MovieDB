//
//  MovieDBReducer.swift
//  MovieDB
//
//  Created by allie on 7/11/2022.
//

import Foundation
import ComposableArchitecture

struct MovieDBReducer: ReducerProtocol {
    
    enum Tab: String, CaseIterable, Identifiable {
        var id: Self { self }
        
        case search
        case discover
        case movies
        case tvShows
        
        var systemImage: String {
            switch self {
            case .search: return "magnifyingglass"
            case .discover: return "star"
            case .movies: return "popcorn"
            case .tvShows: return "sparkles.tv"
            }
        }
    }
    
    struct State: Equatable {
        var selectedTab: Tab? = .discover
        var search: SearchReducer.State = .init()
        var discover: DiscoverReducer.State = .init()
        var movies: DiscoverMediaReducer.State = .init(mediaType: .movie, name: Tab.movies.rawValue.localized)
        var tvShows: DiscoverMediaReducer.State = .init(mediaType: .tv, name: Tab.tvShows.rawValue.localized)
    }
    
    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case tabSelected(Tab?)
        case search(SearchReducer.Action)
        case discover(DiscoverReducer.Action)
        case movies(DiscoverMediaReducer.Action)
        case tvShows(DiscoverMediaReducer.Action)
    }
        
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.discover, action: /Action.discover) {
            DiscoverReducer()
        }
        Scope(state: \.search, action: /Action.search) {
            SearchReducer()
        }
        Scope(state: \.movies, action: /Action.movies) {
            DiscoverMediaReducer()
        }
        Scope(state: \.tvShows, action: /Action.tvShows) {
            DiscoverMediaReducer()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(let action):
                if action.keyPath == \.search.$query, state.search.query.isEmpty {
                    state.search = .init()
                    state.selectedTab = .discover
                }
                return .none
                
            case .tabSelected(let tab):
                state.selectedTab = tab
                state.search = .init()
                return .none
                
            case .search(.search):
                state.selectedTab = .search
                return .none
                
            case .search:
                return .none
                
            case .discover:
                return .none
                
            case .movies:
                return .none
                
            case .tvShows:
                return .none
            }
        }
    }
}
