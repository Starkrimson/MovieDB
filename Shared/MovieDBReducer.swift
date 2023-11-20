//
//  MovieDBReducer.swift
//  MovieDB
//
//  Created by allie on 7/11/2022.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MovieDBReducer {

    enum Tab: String, CaseIterable, Identifiable {
        var id: Self { self }

        case search = "SEARCH"
        case discover = "DISCOVER"
        case movies = "MOVIES"
        case tvShows = "TV SHOWS"
        case people = "POPULAR PEOPLE"

        case favourite = "MY FAVOURITES"
        case watchlist = "WATCHLIST"

        var systemImage: String {
            switch self {
            case .search: return "magnifyingglass"
            case .discover: return "star"
            case .movies: return "popcorn"
            case .tvShows: return "sparkles.tv"
            case .people: return "person.2"
            case .favourite: return "heart"
            case .watchlist: return "list.bullet"
            }
        }
    }

    struct State: Equatable {
        var selectedTab: Tab? = .discover
        var path = StackState<Route.State>()
        var search: SearchReducer.State = .init()
        var discover: DiscoverReducer.State = .init()
        var movies: DiscoverMediaReducer.State = .init(mediaType: .movie, name: Tab.movies.rawValue.localized)
        var tvShows: DiscoverMediaReducer.State = .init(mediaType: .tvShow, name: Tab.tvShows.rawValue.localized)
        var people: DiscoverMediaReducer.State = .init(mediaType: .person, name: Tab.people.rawValue.localized)
        var favourites: FavouriteReducer.State = .init()
        var watchlist: WatchlistReducer.State = .init()
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case tabSelected(Tab?)
        case path(StackAction<Route.State, Route.Action>)
        case search(SearchReducer.Action)
        case discover(DiscoverReducer.Action)
        case movies(DiscoverMediaReducer.Action)
        case tvShows(DiscoverMediaReducer.Action)
        case people(DiscoverMediaReducer.Action)
        case favourites(FavouriteReducer.Action)
        case watchlist(WatchlistReducer.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.discover, action: \.discover) {
            DiscoverReducer()
        }
        Scope(state: \.search, action: \.search) {
            SearchReducer()
        }
        Scope(state: \.movies, action: \.movies) {
            DiscoverMediaReducer()
        }
        Scope(state: \.tvShows, action: \.tvShows) {
            DiscoverMediaReducer()
        }
        Scope(state: \.people, action: \.people) {
            DiscoverMediaReducer()
        }
        Scope(state: \.favourites, action: \.favourites) {
            FavouriteReducer()
        }
        Scope(state: \.watchlist, action: \.watchlist) {
            WatchlistReducer()
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

            case .people:
                return .none

            case .favourites:
                return .none

            case .watchlist:
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Route()
        }
    }
}
