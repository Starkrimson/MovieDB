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

struct SearchReducer: ReducerProtocol {

    struct State: Equatable {
        @BindableState var query: String = ""

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

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .search(let page):
                enum SearchID: Hashable { }

                if state.query.isEmpty {
                    return .none
                }
                state.status = .loading
                return .task { [query = state.query] in
                    await .searchResponse(TaskResult<PageResponses<Media>> {
                        try await dbClient.search(query, page)
                    })
                }
                .animation()
                .cancellable(id: SearchID.self)

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
