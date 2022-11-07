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
        
        case discover
        case movies
        case tvShows
        
        var systemImage: String {
            switch self {
            case .discover: return "star"
            case .movies: return "popcorn"
            case .tvShows: return "sparkles.tv"
            }
        }
    }
    
    struct State: Equatable {
        var selectedTab: Tab? = .discover
    }
    
    enum Action: Equatable {
        case tabSelected(Tab?)
    }
        
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}
