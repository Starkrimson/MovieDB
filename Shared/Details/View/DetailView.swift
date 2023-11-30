//
//  DetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    let store: StoreOf<DetailReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                Header(state: viewStore.state)

                switch viewStore.status {
                case .loading: ProgressView()
                case .error(let error):
                    ErrorTips(error: error)
                case .normal:
                    IfLetStore(store.scope(state: \.detail, action: { $0 })) { letStore in
                        SwitchStore(letStore) { initialState in
                            switch initialState {
                            case .movie:
                                CaseLet(
                                    state: /DetailReducer.DetailState.movie,
                                    then: MovieDetailView.init
                                )

                            case .tvShow:
                                CaseLet(
                                    state: /DetailReducer.DetailState.tvShow,
                                    then: TVDetailView.init
                                )

                            case .person:
                                CaseLet(
                                    state: /DetailReducer.DetailState.person,
                                    then: PersonDetailView.init
                                )
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    ExternalLinkMenu(
                        displayName: viewStore.media.displayName,
                        detailState: viewStore.detail
                    )
                }
                if viewStore.media.mediaType != .person {
                    ToolbarItem {
                        Button {
                            viewStore.send(.addToWatchList)
                        } label: {
                            Label(
                                "WATCHLIST".localized,
                                systemImage: viewStore.isInWatchList ? "bookmark.fill" : "bookmark"
                            )
                        }
                        .help(
                            viewStore.isInWatchList
                            ? "REMOVE FROM YOUR WATCHLIST".localized
                            : "ADD TO YOUR WATCHLIST".localized
                        )
                    }
                }
                ToolbarItem {
                    Button {
                        viewStore.send(.markAsFavourite)
                    } label: {
                        Label("FAVOURITE".localized, systemImage: viewStore.isFavourite ? "heart.fill" : "heart")
                    }
                    .help(
                        viewStore.isFavourite
                        ? "REMOVE FROM YOUR FAVORITE LIST".localized
                        : "MARK AS FAVOURITE".localized
                    )
                }
            }
            .navigationTitle(viewStore.media.displayName)
            .task {
                viewStore.send(.fetchDetails)
            }
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            store: .init(
                initialState: .init(media: mockMedias[2]),
                reducer: { DetailReducer() }
            )
        )
        .frame(height: 850)
    }
}
#endif
