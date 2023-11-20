//
//  Route.swift
//  MovieDB
//
//  Created by allie on 17/11/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Route {

    enum State: Equatable, Hashable {
        case detail(DetailReducer.State)
        case season(SeasonReducer.State)
        case episode(EpisodeReducer.State)
        case movieCollection(MovieCollectionReducer.State)
        case discoverMedia(DiscoverMediaReducer.State)
        case credit(CreditReducer.State)
    }

    enum Action: Equatable {
        case detail(DetailReducer.Action)
        case season(SeasonReducer.Action)
        case episode(EpisodeReducer.Action)
        case movieCollection(MovieCollectionReducer.Action)
        case discoverMedia(DiscoverMediaReducer.Action)
        case credit(CreditReducer.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.detail, action: \.detail) {
            DetailReducer()
        }
        Scope(state: \.season, action: \.season) {
            SeasonReducer()
        }
        Scope(state: \.episode, action: \.episode) {
            EpisodeReducer()
        }
        Scope(state: \.movieCollection, action: \.movieCollection) {
            MovieCollectionReducer()
        }
        Scope(state: \.discoverMedia, action: \.discoverMedia) {
            DiscoverMediaReducer()
        }
        Scope(state: \.credit, action: \.credit) {
            CreditReducer()
        }
    }
}

import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
extension NavigationLink where Destination == Never {

    init<L: View>(
        route: Route.State,
        @ViewBuilder label: () -> L,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) where Label == _NavigationLinkStoreContent<Route.State, L> {
        self.init(state: route, label: label, fileID: fileID, line: line)
    }
}
