//
//  MediaFilterReducer.swift
//  MovieDB
//
//  Created by allie on 11/11/2022.
//

import Foundation
import ComposableArchitecture

struct MediaFilterReducer: ReducerProtocol {

    struct State: Equatable {
        @BindableState var sortBy: String = "popularity.desc"

        @BindableState var minimumUserScore: Int = 0
        @BindableState var maximumUserScore: Int = 10

        @BindableState var minimumUserVotes: Int = 0

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

    var body: some ReducerProtocol<State, Action> {
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
