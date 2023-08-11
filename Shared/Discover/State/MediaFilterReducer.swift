//
//  MediaFilterReducer.swift
//  MovieDB
//
//  Created by allie on 11/11/2022.
//

import Foundation
import ComposableArchitecture

struct MediaFilterReducer: Reducer {

    struct State: Equatable {
        @BindingState var sortBy: String = "popularity.desc"

        @BindingState var minimumUserScore: Int = 0
        @BindingState var maximumUserScore: Int = 10

        @BindingState var minimumUserVotes: Int = 0

        var filters: [URL.DiscoverQueryItem] {
            [
                .sortBy(sortBy),
                .voteCountGTE(minimumUserVotes),
                .voteAverageGTE(minimumUserScore),
                .voteAverageLTE(maximumUserScore)
            ]
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case reset
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .reset:
                state = .init()
                return .none
            }
        }
    }
}
