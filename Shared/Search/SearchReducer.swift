//
//  SearchReducer.swift
//  MovieDB
//
//  Created by allie on 7/11/2022.
//

import Foundation
import ComposableArchitecture

enum ViewStatus: Equatable, Hashable {
    case normal, loading, error(String)
}

@Reducer
struct SearchReducer {

    struct State: Equatable {
        @BindingState var query: String = ""

        var page: Int = 1
        var totalPages: Int = 1
        var list: IdentifiedArrayOf<Media> = []

        var status: ViewStatus = .normal

        var isLastPage: Bool { page >= totalPages }
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case search(page: Int = 1)
        case searchResponse(TaskResult<PageResponses<Media>>)
    }

    @Dependency(\.dbClient) var dbClient

    enum SearchID { case query }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .search(let page):
                if state.query.isEmpty {
                    return .none
                }
                state.status = .loading
                return .run { [query = state.query] send in
                    await send(.searchResponse(TaskResult<PageResponses<Media>> {
                        try await dbClient.search(query, page)
                    }))
                }
                .animation()
                .cancellable(id: SearchID.query)

            case .searchResponse(.success(let value)):
                state.page = value.page ?? 1
                state.totalPages = value.totalPages ?? 1
                state.status = .normal
                if value.page == 1 {
                    state.list.removeAll()
                }
                state.list.append(contentsOf: value.results ?? [])
                return .none

            case .searchResponse(.failure(let error)):
                state.status = .error(error.localizedDescription)
                return .none
            }
        }
    }
}
