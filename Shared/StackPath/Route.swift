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
    }

    enum Action: Equatable {
        case detail(DetailReducer.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.detail, action: \.detail) {
            DetailReducer()
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
