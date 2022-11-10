//
//  DiscoverMediaState.swift
//  MovieDB
//
//  Created by allie on 1/8/2022.
//

import Foundation
import ComposableArchitecture

struct DiscoverMediaReducer: ReducerProtocol {
    
    struct State: Equatable {
        let mediaType: MediaType
        let name: String
        
        var filters: [URL.DiscoverQueryItem] = []

        var page: Int = 1
        var quickSort: QuickSort = .popular
        var totalPages: Int = 1
        var list: IdentifiedArrayOf<Media> = []
        
        var status: ViewStatus = .loading
        
        var isLastPage: Bool { page >= totalPages }
        
        enum QuickSort: String, CaseIterable, Identifiable {
            var id: Self { self }
            case popular
            case topRated = "Top Rated"
        }
    }
    
    enum Action: Equatable {
        case fetchMedia(loadMore: Bool = false)
        case fetchMediaDone(loadMore: Bool, result: TaskResult<PageResponses<Media>>)
        case setQuickSort(State.QuickSort)
    }
    
    @Dependency(\.dbClient) var dbClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchMedia(let loadMore):
                state.status = .loading
                return .task { [state] in
                    await .fetchMediaDone(loadMore: loadMore, result: TaskResult<PageResponses<Media>> {
                        try await dbClient
                            .discover(
                                state.mediaType,
                                state.filters + [ .page(loadMore ? state.page + 1 : 1) ]
                            )
                    })
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
                state.page = 1
                state.totalPages = 1
                if quickSort == .popular {
                    state.filters = []
                } else {
                    state.filters = [
                        .sortBy("vote_average.desc"),
                        .voteCountGTE(300)
                    ]
                }
                return .task {
                    .fetchMedia()
                }
            }
        }
    }
}
