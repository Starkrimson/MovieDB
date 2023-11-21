//
//  DiscoverMediaState.swift
//  MovieDB
//
//  Created by allie on 1/8/2022.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DiscoverMediaReducer {

    enum QuickSort: String, CaseIterable, Identifiable {
        var id: Self { self }
        case popular = "POPULAR"
        case topRated = "TOP RATED"
    }

    struct State: Equatable, Hashable {

        let mediaType: MediaType
        let name: String

        /// 用作初始化的 filter，区分 keywords 或者 genres
        var filters: [URL.DiscoverQueryItem] = []

        var page: Int = 1
        var quickSort: QuickSort = .popular
        var totalPages: Int = 1
        var list: IdentifiedArrayOf<Media> = []

        var status: ViewStatus = .loading

        var filter: MediaFilterReducer.State = .init()

        var isLastPage: Bool { page >= totalPages }
    }

    enum Action: Equatable {
        case fetchMedia(loadMore: Bool = false)
        case fetchMediaDone(loadMore: Bool, result: TaskResult<PageResponses<Media>>)
        case setQuickSort(QuickSort)
        case filter(MediaFilterReducer.Action)
    }

    @Dependency(\.dbClient) var dbClient

    var body: some Reducer<State, Action> {
        Scope(state: \.filter, action: /Action.filter) {
            MediaFilterReducer()
        }
        Reduce { state, action in
            switch action {
            case .fetchMedia(let loadMore):
                if !loadMore {
                    state.page = 1
                    state.totalPages = 1
                }
                state.status = .loading
                return .run { [state] send in
                    await send(.fetchMediaDone(loadMore: loadMore, result: TaskResult<PageResponses<Media>> {
                        if state.mediaType == .person {
                            return try await dbClient
                                .popular(.person, loadMore ? state.page + 1 : 1)
                        } else {
                            return try await dbClient
                                .discover(
                                    state.mediaType,
                                    state.filters + [ .page(loadMore ? state.page + 1 : 1) ] + state.filter.filters
                                )
                        }
                    }))
                }
                .animation()

            case .fetchMediaDone(let loadMore, result: .success(let value)):
                state.status = .normal
                state.page = value.page ?? 1
                state.totalPages = value.totalPages ?? 1
                let list = value.results ?? []
                if !loadMore {
                    state.list.removeAll()
                }
                state.list.append(contentsOf: list)
                return .none

            case .fetchMediaDone(_, result: .failure(let error)):
                state.status = .error(error.localizedDescription)
                return .none

            case .setQuickSort(let quickSort):
                state.quickSort = quickSort
                if quickSort == .popular {
                    state.filter = .init()
                } else {
                    state.filter = .init(sortBy: "vote_average.desc", minimumUserVotes: 300)
                }
                return .send(.fetchMedia())

            case .filter(let action):
                if action == .reset {
                    state.quickSort = .popular
                }
                return .send(.fetchMedia())
            }
        }
    }
}
