//
//  ContentView.swift
//  Shared
//
//  Created by allie on 30/6/2022.
//

import SwiftUI
import CoreData
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<MovieDBReducer> = .init(
        initialState: .init(),
        reducer: { MovieDBReducer() }
    )

    let tabs: [(title: String, items: [MovieDBReducer.Tab])] = [
        ("MovieDB", [.discover, .movies, .tvShows, .people]),
        ("LIBRARY".localized, [.favourite, .watchlist])
    ]

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            NavigationSplitView {
                VStack {
                    List(
                        selection: viewStore.binding(
                            get: { $0.selectedTab },
                            send: MovieDBReducer.Action.tabSelected
                        )
                    ) {
                        ForEach(tabs, id: \.title) { section in
                            Section(section.title) {
                                ForEach(section.items) { item in
                                    Label(item.rawValue.localized, systemImage: item.systemImage)
                                }
                            }
                        }
                    }
                    Spacer()
                    Link(destination: URL(string: "https://www.themoviedb.org")!) {
                        HStack(spacing: 3) {
                            Image(systemName: "globe")
                            Text("themoviedb.org")
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 6)
                    }
                }
                .searchable(
                    text: viewStore.binding(
                        get: { $0.search.query },
                        send: { MovieDBReducer.Action.binding(.set(\.search.$query, $0)) }
                    ),
                    placement: .sidebar,
                    prompt: "SEARCH PLACEHOLDER".localized
                )
                .onSubmit(of: .search) {
                    viewStore.send(.search(.search()))
                }
            } detail: {
                NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
                    switch viewStore.selectedTab {
                    case .search:
                        SearchResultsView(store: store.scope(
                            state: \.search, action: MovieDBReducer.Action.search)
                        )

                    case .discover:
                        DiscoverView(
                            store: store.scope(
                                state: \.discover,
                                action: MovieDBReducer.Action.discover
                            )
                        )

                    case .movies:
                        DiscoverMediaView(
                            store: store.scope(
                                state: \.movies,
                                action: MovieDBReducer.Action.movies
                            )
                        )

                    case .tvShows:
                        DiscoverMediaView(
                            store: store.scope(
                                state: \.tvShows,
                                action: MovieDBReducer.Action.tvShows
                            )
                        )

                    case .people:
                        DiscoverMediaView(
                            store: store.scope(
                                state: \.people,
                                action: MovieDBReducer.Action.people
                            )
                        )

                    case .favourite:
                        FavouriteList(
                            store: store.scope(
                                state: \.favourites,
                                action: MovieDBReducer.Action.favourites
                            )
                        )

                    case .watchlist:
                        WatchlistView(
                            store: store.scope(
                                state: \.watchlist,
                                action: MovieDBReducer.Action.watchlist
                            )
                        )

                    case .none:
                        EmptyView()
                    }
                } destination: { path in
                    switch path {
                    case .detail:
                        CaseLet(
                            /Route.State.detail,
                             action: Route.Action.detail,
                             then: DetailView.init(store:)
                        )
                    case .season:
                        CaseLet(
                            /Route.State.season,
                             action: Route.Action.season,
                             then: EpisodeList.init(store:)
                        )
                    case .episode:
                        CaseLet(
                            /Route.State.episode,
                             action: Route.Action.episode,
                             then: EpisodeView.init(store:)
                        )
                    case .movieCollection:
                        CaseLet(
                            /Route.State.movieCollection,
                             action: Route.Action.movieCollection,
                             then: MovieCollectionView.init(store:)
                        )
                    case .discoverMedia:
                        CaseLet(
                            /Route.State.discoverMedia,
                             action: Route.Action.discoverMedia,
                             then: DiscoverMediaView.init(store:)
                        )
                    case .credit:
                        CaseLet(
                            /Route.State.credit,
                             action: Route.Action.credit,
                             then: CreditView.init(store:)
                        )
                    case .imageGrid:
                        CaseLet(
                            /Route.State.imageGrid,
                             action: Route.Action.imageGrid,
                             then: { ImageGridView(store: $0) }
                        )
                    case .image:
                        CaseLet(
                            /Route.State.image,
                             action: Route.Action.image,
                             then: { ImageBrowser(store: $0) }
                        )
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
